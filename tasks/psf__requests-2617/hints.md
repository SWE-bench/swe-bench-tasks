Unfortunately this is a bit of a limitation imposed on us by httplib. As you can see, the place where unicode and bytes are concatenated together is actually deep inside httplib. I'm afraid you'll have to pass bytestrings to requests.

Can you explain why it works fine when the request isn't prepared? That seems inconsistent.

Because the higher level code coerces your strings to the platform-native string type (bytes on Python 2, unicode on Python 3). One of the problems when you step this 'more control' abstraction is that we stop doing some of the helpful things we do at the higher abstraction levels.

We have a `to_native_string` function that you could use (it's what we use).

I'll check that out. Thanks.

@bboe it's in your best interest to copy and paste `to_native_string` out of requests though. It's an undocumented function that's effectively meant to be internal to requests. If we move it around or change something in it, it could cause compatibility problems for you and there's no guarantee of backwards compatibility for that function as it isn't a defined member of the API.

That said, @Lukasa and I agree that it's highly unlikely to break, change, or disappear. So, while I'd prefer you to copy and paste it out, there's nothing I can do to enforce that. ;)

As it turns out, only the request `method` needs to be in the right format. In my above example changing:

```
    request = requests.Request(method='PUT', url='https://httpbin.org/put')
```

to

```
    request = requests.Request(method=to_native_string('PUT'), url='https://httpbin.org/put')
```

is all that is needed. Maybe this simple of a fix could be included in requests?

I'm frankly starting to wonder why we don't do all of this `to_native_string` work when we prepare the request in the first place. It seems like the more correct place for this conversion than [here](https://github.com/kennethreitz/requests/blob/a0d9e0bc57c971823811de38e5733b4b85e575ae/requests/sessions.py#L436).

Suits me. =)
