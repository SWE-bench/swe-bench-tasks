Is that error output from response.content or response.text? If it's text, can you show me response.content please?

Could you also show us

``` py
print(response.request.url)
print(response.history)
for resp in response.history:
    print('---')
    print('Request URI: {}'.format(resp.request.url))
    print('Status: {}'.format(resp.status_code))
    print('Location: {}'.format(resp.headers['Location']))
```

Hello, thanks for your answer.

@Lukasa 
This is both from response.text and from response.content:

``` python
In [3]: r = requests.get("http://test.みんな")
In [5]: r.text
Out[5]: '<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">\n<html><head>\n<title>404 Not Found</title>\n</head><body>\n<h1>Not Found</h1>\n<p>The requested URL /Ã£Â\x83Â\x96Ã£Â\x83Â\xadÃ£Â\x82Â°/ was not found on this server.</p>\n<hr>\n<address>Apache/2.2.15 (CentOS) Server at test.xn--q9jyb4c Port 80</address>\n</body></html>\n'
In [6]: r.content
Out[6]: b'<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">\n<html><head>\n<title>404 Not Found</title>\n</head><body>\n<h1>Not Found</h1>\n<p>The requested URL /\xc3\xa3\xc2\x83\xc2\x96\xc3\xa3\xc2\x83\xc2\xad\xc3\xa3\xc2\x82\xc2\xb0/ was not found on this server.</p>\n<hr>\n<address>Apache/2.2.15 (CentOS) Server at test.xn--q9jyb4c Port 80</address>\n</body></html>\n'
```

@sigmavirus24 

``` python
In [9]: r.request.url
Out[9]: 'http://test.xn--q9jyb4c/%C3%A3%C2%83%C2%96%C3%A3%C2%83%C2%AD%C3%A3%C2%82%C2%B0/'

In [11]: r.history
Out[11]: [<Response [302]>]

In [13]: for resp in r.history:
   ....:         print('---')
   ....:         print('Request URI: {}'.format(resp.request.url))
   ....:         print('Status: {}'.format(resp.status_code))
   ....:         print('Location: {}'.format(resp.headers['Location']))
---
Request URI: http://test.xn--q9jyb4c/
Status: 302
Location: http://test.xn--q9jyb4c/ãã­ã°/
```

Maybe it is also a problem that the Apache server sends the header in ISO-8859-1? But this would likely be a problem of the shared hoster setup, I guess?

``` python
In [21]: r.history[0].headers
Out[21]: {'server': 'Apache/2.2.15 (CentOS)', 'content-type': 'text/html; charset=iso-8859-1', 'location': 'http://test.xn--q9jyb4c/ã\x83\x96ã\x83\xadã\x82°/', 'content-length': '328', 'date': 'Sat, 27 Jun 2015 19:02:37 GMT', 'connection': 'close'}
```

I am sorry that I have obfuscated my original domain. Can I somehow privately send it to you? I would not really like to have it here on Github for all eternity, but of course I have no problem sending it directly to you so that you can check it out.

So it looks like the redirect URI is encoded in shift-JIS. Requests receives those bytes and puts them back on the wire. I wonder if we're hurting when we round trip.

You can mail me at cory [at] lukasa [dot] co [dot] uk.

Ok, this is a Python 3 bug. Everything works fine if I use Python 2. This is because on Python 2 the bytestring Location header is treated as a bytestring, which we turn into a bytestring URI, which we then correctly percent-encode and send back to urllib3.

Python 3 doesn't work like that. If I use httplib directly:

``` python
>>> import http.client
>>> c = http.client.HTTPConnection('変哲もない.みんな', 80)
>>> c.request('GET', '/')
>>> r = c.getresponse()
>>> r.getheader('Location')
'http://xn--n8jyd3c767qtje.xn--q9jyb4c/ã\x83\x96ã\x83\xadã\x82°/'
```

Notice that this is a unicode string, but it's weirdly a Latin-1 encoded string. I think somewhere in our stack we're re-encoding this as UTF-8, where we should re-encode it as Latin-1.

Ok, this problem seems to boil down to our `requote_uri` function:

``` python
>>> url = 'http://xn--n8jyd3c767qtje.xn--q9jyb4c/ã\x83\x96ã\x83\xadã\x82°/'
>>> requote_uri(url)
'http://xn--n8jyd3c767qtje.xn--q9jyb4c/%C3%A3%C2%83%C2%96%C3%A3%C2%83%C2%AD%C3%A3%C2%82%C2%B0/'
```

This is the wrong URI: specifically, it has been treated as utf-8 and it should have been treated as latin-1.

The problem actually appears to be with passing the string directly to `urllib.parse.quote`:

``` python
>>> from urllib.parse import quote
>>> >>> quote('/ã\x83\x96ã\x83\xadã\x82°/')
'/%C3%A3%C2%83%C2%96%C3%A3%C2%83%C2%AD%C3%A3%C2%82%C2%B0/'
>>> quote('/ã\x83\x96ã\x83\xadã\x82°/'.encode('latin1'))
'/%E3%83%96%E3%83%AD%E3%82%B0/'
```

So, my bet is that `quote` makes a UTF-8 assumption that is simply not valid.

Yup, just checked the code: that's exactly what it does.

So, this is a bit tricky now. I _think_ we want to round-trip through `Latin1`, but I have to work out where best to do it.

Or is it rather a problem of the Apache setup on my web hoster? Because it replies as ISO-8859-1, not as UTF-8.

No, I think Python screwed this up. Out of interest, if it's easy, can you set it to reply with UTF-8 and see if that changes anything?

Sorry, I guess not, I don't have root access. It is a shared hoster (albeit a really cool one; www.uberspace.de). 

My suspicion is that Python's httplib is decoding the header as latin 1, which means if we re-encode with latin 1 we'll get exactly the bytes your server sent. I need to confirm that though. Time to dumpster dive through the code. ;)

Yup, httplib definitely decodes as 'iso-8859-1' on Python 3. Ok, we can do special case hellishness to fix this. =D

It's a little frustrating that these two parts of the stdlib are inconsistent, but there we go.
