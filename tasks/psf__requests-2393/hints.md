This bug is exactly the same as #1360, with one key difference: here, the server isn't percent-encoding percent signs. This is not valid HTTP, and we're totally allowed to fail here according to RFC 7231:

> Note: Some recipients attempt to recover from Location fields that are not valid URI references.  This specification does not mandate or define such processing, but does allow it for the sake of robustness.

However, I wonder if we can do better. Specifically, I wonder if we can update our `requote_uri` function to allow us to attempt to unquote it, and if that fails because of invalid percent-escape sequences we can just use the URL unchanged. That probably covers most of our bases, and it's gotta be better than failing hard like we do now.

@sigmavirus24, thoughts?

I'm +0 on the idea but my opinion really depends on the complexity of the fix.

So, looking at this again, I did tried the following:

``` py
>>> import requests
>>> r = requests.get('http://bit.ly/1x5vKWM', allow_redirects=False)
>>> r
<Response [301]>
>>> r.headers['Location']
'http://ad.doubleclick.net/ddm/clk/285880402;112768085;k'
>>> r2 = requests.get(r.headers['Location'], allow_redirects=False)
>>> r2
<Response [302]>
>>> r2.headers['Location']
'http://style.shoedazzle.com/dmg/3AE3B8?dzcode=FBT&dzcontent=FBT_SDZ_CPM_Q414&pid=112768085&aid=285880402&cid=0&publisher=%ppublisher=!;&placement=%pplacement=!;'
>>> r3 = requests.get(r2.headers['Location'], allow_redirects=False)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File ".../virtualenv/twine/lib/python2.7/site-packages/requests/api.py", line 65, in get
    return request('get', url, **kwargs)
  File ".../virtualenv/twine/lib/python2.7/site-packages/requests/api.py", line 49, in request
    response = session.request(method=method, url=url, **kwargs)
  File ".../virtualenv/twine/lib/python2.7/site-packages/requests/sessions.py", line 447, in request
    prep = self.prepare_request(req)
  File ".../virtualenv/twine/lib/python2.7/site-packages/requests/sessions.py", line 378, in prepare_request
    hooks=merge_hooks(request.hooks, self.hooks),
  File ".../virtualenv/twine/lib/python2.7/site-packages/requests/models.py", line 304, in prepare
    self.prepare_url(url, params)
  File ".../virtualenv/twine/lib/python2.7/site-packages/requests/models.py", line 400, in prepare_url
    url = requote_uri(urlunparse([scheme, netloc, path, None, query, fragment]))
  File ".../virtualenv/twine/lib/python2.7/site-packages/requests/utils.py", line 424, in requote_uri
    return quote(unquote_unreserved(uri), safe="!#$%&'()*+,/:;=?@[]~")
  File ".../virtualenv/twine/lib/python2.7/site-packages/requests/utils.py", line 404, in unquote_unreserved
    raise InvalidURL("Invalid percent-escape sequence: '%s'" % h)
requests.exceptions.InvalidURL: Invalid percent-escape sequence: 'pp'
```

I assume this is something along the lines of what @suhaasprasad is seeing. I'm going to see if following @Lukasa's idea will work for this.
