You answered your own question when you pasted that line. The comment explains exactly why we consume the content. If we do not, then a user handling a great deal of redirects will run out of available connections that can be made. Sockets will sit in the ready state waiting to be read from. I think it also has the potential to cause a memory usage issue when the ref count does not reach 0 and the socket is not garbage collected. We should be, however, catching that error in `resolve_redirects`.

Thank you for raising this issue! I'll throw together a PR to patch this.

I agree that consuming the raw response data from the socket is needed. I'm asking why we should _decode_ the data.

(And thanks for the quick response.)

We decode the data because your assertion that it won't be read is false. You may read the response body from any redirect because we save it. Each redirect builds a _full_ response object that can be used exactly like any other. This is a very good thing, and won't be changed. =)

The fix, as @sigmavirus24 has suggested, is simply to catch this error.

Interesting. It's very likely that this is a duplicate of https://github.com/shazow/urllib3/issues/206 / https://github.com/kennethreitz/requests/issues/1472 because there is also an 301 redirect in the curl output. @shazow 

@schlamar That's very interesting.

However, this isn't a dupe, it's just related. The key is that we shouldn't really care even if we hit a legitimate decoding error when following redirects: we just want to do our best and then move on.

@Lukasa hit the nail on the head :)

> However, this isn't a dupe, it's just related.

Why do you think so? 

On requests 1.2.3, I'm getting the same traceback than in #1472 with this URL:

```
>>> import requests ; requests.get('http://www.whatbird.com/forum/index.php?/gallery/image/291517-foo/')
Traceback (most recent call last):
  ...
  File "c:\Python27\lib\site-packages\requests\packages\urllib3\response.py", line 188, in read
    "failed to decode it." % content_encoding)
requests.packages.urllib3.exceptions.DecodeError: Received response with content-encoding: gzip, but failed to decode it
```

@schlamar So the issues you linked cause the exception, but they aren't the problem being referred to. The key problem in _this_ issue is that if we hit an error decoding the response body of a redirect, we'll stop following redirects. That _shouldn't_ happen: we understood enough of the message to follow the redirect, so there's no reason to stop following them. =)

Fixing the bugs you linked fixes the specific case in question, but not the general one.

> Fixing the bugs you linked fixes the specific case in question, but not the general one.

Yes, but fixing _this_ bug should resolve the linked issues (which is what I wanted to say :)

Ahhhhh, I see. =)
