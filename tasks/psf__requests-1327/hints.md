> This is because there is already a default adapter for 'http://' in the form of requests.adapters.HTTPAdapter. Depending on the (seemingly random) order of keys in the s.adapters dictionary, for some combinations of keys it will work, for others it won't.

**EDIT** None of the information in this comment is correct. There's nothing to see here except my embarrassment.

This has nothing to do with dictionary order. When we look an adapter we're looking for an adapter based on protocol, not hostname. We use `urlparse` to get the scheme (or protocol) and then we look for that in the adapters dictionary. With this in mind you get

``` python
uri = urlparse('http://test.com')
assert uri.scheme == 'http://'
assert uri.host == 'http://'
```

And we do `self.adapters.get(uri.scheme)` I believe. You would have to monkey patch `get_adapter` to get the behaviour you want.

That's how we do it now. As for the docs, I have no clue why that example is there because it is just plain wrong. Setting up an adapter for that though would probably be convenient for quite a few people though. One concern I have, though, is that it is a change that sort of breaks the API despite being documented as working that way.

@Lukasa ideas?

Actually, @ambv is right. Here's the source code for `get_adapter()`:

``` python
def get_adapter(self, url):
    """Returns the appropriate connnection adapter for the given URL."""
    for (prefix, adapter) in self.adapters.items():
        if url.startswith(prefix):
            return adapter

    # Nothing matches :-/
    raise InvalidSchema("No connection adapters were found for '%s'" % url)
```

This is awkward, because I've provided Transport Adapter information in the past that directly contradicts this behaviour. I think we need to fix this, because the docs behaviour should be correct. I'm happy to take a swing at this.

I am sincerely sorry @ambv. That'll teach me to work from memory ever again. 

Here are my thoughts about this with the code above:
- We could collect a list of matching adapters instead of returning the first one we find. The problem is then deciding which adapter to use
- We could maintain two separate adapters registries: 1) user-created 2) default. The user-created adapters would be the first to be searched through and if there's a match in them we could then return that. If none of those match we would then search the default adapters and if nothing matches from there raise the `InvalidSchema` error. To preserve the API we could make `adapters` a property. The `@adapters.setter` method would then only set adapters on the user-created dictionary. The returned information would then be best represented as a list of two-tuples where the user-created items come first and is then followed by the default. This gives an intuitive idea of the overall ordering of discovery of adapters. This, however, would break the case where someone tries to do `session.adapters['http://']`
- We could create our own `AdaptersRegistry` object which behaves like a dictionary, i.e., has the `__setitem__`, `__getitem__`, `get`, `set`, &c., methods, and does the search for us. Then we just maintain that as the `adapters` attribute.

I could be vastly over-thinking the problem though.

I think we're totally over-engineering this. If we were going to do this properly we'd implement a trie and cause it to mimic the dictionary interface (not hard).

The reality is, we don't need to. We can assert that the number of transport adapters plugged into any session is likely to be small. If that's the case, we should just do:

``` python
best = ''
for key, adapter in self.adapters.items():
    if url.startswith(key) and (len(best) < len(key)):
        best = key

return self.adapters.get(best, None)
```

This way we don't have to maintain a new data structure. Unless @kennethreitz wants to, of course, in which case I'll happily whip up a pure-Python trie. =)

> I think we're totally over-engineering this.

s/we/you (where you is me) ;)

And yeah that does sound like it should work.

One of the valid use cases for adapters is unit testing. Tests should run as fast as possible, spending time sorting adapters in place every time is wasteful. I don't like the approach taken in #1323 because `get_adapter()` is called for every single request.

I'd like @kennethreitz to weigh in here whether he considers session.adapters a public API. For what it's worth this attribute is not listed in the "Developers Interface" section of the docs here: http://www.python-requests.org/en/latest/api/#request-sessions

Respectfully, I disagree.

Yes, it's not completely optimised. However, you have to consider the use cases. The overwhelming majority of cases will have two adapters installed: the defaults. My fix adds one-half of a dictionary iteration (on average), plus four length checks in this case. The next highest number of cases will have one other adapter in place. This means my fix adds one dictionary iteration (on average), plus six length checks. Actually, my performance is better, because we only do the length check if the prefix matches (so if we're doing HTTP, we don't do a length check on `'https://'`).

For perspective, on a GET request in Requests as we speak, we hit the following:

```
   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
7975/7767    0.001    0.000    0.001    0.000 {len}
       66    0.000    0.000    0.000    0.000 {method 'items' of 'dict' objects}
```

Even being generous and saying we would save six calls to `len` is barely a drop in the water.

Iterating over a dictionary isn't slow either. Using the following test code:

``` python
a = {'hi': 'there', 'hello': 'there', 'sup': 'yo'}

for i in range(0, 1000000):
    for key, value in a.items():
        pass
```

Running it in my shell and using `time` (so I'm also bearing the startup and teardown cost of the VM), we get:

```
python test.py  0.90s user 0.04s system 99% cpu 0.949 total
```

Dividing by the number of iterations gives us 0.949/1000000 = 0.949ms per pass over the dictionary, or 0.3ms per dictionary element. I think we can bear the extra 300 nanoseconds. =)

Let's just do an ordered dict and search backwards for the first compatible adapter.

Doesn't ordered dict mean 'insertion order'? Because that won't actually fix our problem.

Oh, nevermind, we'll just rebuild the dict in the call to `mount()`. Ignore me. =)

Would you mind if I prepare the PR? :)

If that was aimed at me, then the answer is of course not. =)
