Out of interest, what's the use case for this?

I want to use requests with the multiprocessing module and it uses pickle as the serialization method.

I may be able to produce a patch if you give me some directions.

If you want to take a crack at a patch @git2samus, take a look at the Session class. That's picklable and has all the info there. If you would rather one of us do it, I can start to tackle it in half an hour.

You can't pickle the Response as it contains a link to the connection pool. If you aren't reusing connections you might consider the following:

```
r = requests.get('http://example.org')
r.connection.close()
pickle.dumps(r)
```

https://github.com/tanelikaivola/requests/commit/229cca8ef0f8a6703cbdce901c0731cacef2b27e is how I solved it.. Just remove the raw-attribute from the __getstate__.

https://github.com/tanelikaivola/requests/commit/a5360defdc3f91f4178e2aa1d7136a39a06b2a54 is an alternate way of doing it (which mimics the code style of https://github.com/kennethreitz/requests/commit/590ce29743d6c8d68f3885a949a93fdb68f4d142).

Any update on this? I just ran into the same issue trying to cache Responses for testing purposes.

I ended up with something like this:

``` python
r = requests.get('http://example.org')
r.raw = None
pickle.dumps(r)
```

This would be a big help for caching via [Cache Control](https://github.com/ionrock/cachecontrol). At the moment, it is very difficult to cache a response outside of memory because it is difficult to rebuild the object hierarchy.

I did look into caching the raw response and using it to rebuild the response from scratch when a cache is hit, but that would have taken some pretty serious monkey patching of httplib and urllib3.

The patches by @tanelikaivola seem like they would world without too much trouble.

@ionrock why not do something like [Betamax](https://github.com/sigmavirus24/betamax) instead of trying to use pickle?

@sigmavirus24 Thanks for pointing out [Betamax](https://github.com/sigmavirus24/betamax)! I'd argue the serialize/deserialize_response functions would be a great addition to the Response object. If the goal is to avoid pickle, this seems like a great option. Sometimes pickle is a good option though, so I still believe it is worthwhile to add the functionality. I've tested the patch @tanelikaivola and they work well. What else would need to be done to potentially get them merged? Obviously some tests would be helpful. I'd also be happy to see about adding the serialize/deserialize code from Betamax if that would be alright with @sigmavirus24. 

Let me know if there is a good way to proceed. I'd be happy to put the code together. 

@sigmavirus24 thanks again for the Betamax suggestion. I will be switching [Cache Control](https://github.com/ionrock/cachecontrol) to use that methodology.

I'm :-1: for adding the serialize/deserialize code from Betamax to requests. For one, I don't believe it takes care of all of the information that could be serialized. As it is Betamax only serializes what it needs to so that it can maintain compatibility with VCR's cassette format. If other people want it in requests proper, we could do that, but I'm not sure it works very well without the rest of betamax.

@sigmavirus24 Fair enough. I'm most definitely not the expert on everything that a Response object, so I'm happy to take your word for it. When I looked at what a response object contained it was semi-complex as it was a wrapper around a urllib3 HTTPResponse, which is in turn a wrapper around a httplib response, which assumes the content comes directly from a socket (not a file like object). 

With that being the case, it seems to make sense to support pickling of Response object. Again, I'm happy to write some tests for @tanelikaivola's patches if there is a consensus. Otherwise, I'd like to understand where it falls short. At the very least I'd like to try and fix it for myself. 

Thanks for the discussion!

Personally I prefer https://github.com/tanelikaivola/requests/commit/a5360defdc3f91f4178e2aa1d7136a39a06b2a54 so if you want to add tests around that, that would be a great start.
