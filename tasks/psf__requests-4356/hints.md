On dumping the connection object right before calling `conn.urlopen()`, the output for `print(vars(conn))` reveals:
```
'proxy': Url(scheme='http', auth=None, host=None, port=80, path='/my.proxy.com:3128', query=None, fragment=None), 
```
And this makes urllib3 think that the proxy to be reached is: `http://:80/my.proxy.com:3128`
requests calls `prepend_scheme_if_needed()` in the function `get_connection()` and in this case changes the url to http:///my.proxy.com:3128
```
>>> from requests.utils import prepend_scheme_if_needed 
>>> prepend_scheme_if_needed("https:/myproxy.com:3128", "http")
'https:///myproxy.com:3128'
```
... which when passed to parse_url() from `urllib3.util`:
```
>>> from urllib3.util import parse_url
>>> parse_url("https:///myproxy.com:3128")
Url(scheme='https', auth=None, host=None, port=None, path='/myproxy.com:3128', query=None, fragment=None)
```
... makes the host and port vanish.
Yeah, we could maybe have a specific check for a not `None` `host` value, but there's nothing actually wrong in what we're doing. Further, urllib3 is parsing the URI you're providing it, correctly. The authority portion of a URI begins with `//` and contains the userinfo, host, and port. Paths begin with `/` and come after an `authority` or after the scheme which is terminated by `:`. So your typo is actually a valid URI. It just doesn't have an authority section.

So, like I said, we could provide a more understandable exception but in reality, this is RFC 3986 working against you (as well as the fact that we implement it correctly).
Sure, but semantically speaking, an empty `authority` section doesn't make sense for a proxy URI right?
@nehaljwani exactly. This is why I suggest checking for that and raising a more helpful/understandable exception.
> This is why I suggest checking for that and raising a more helpful/understandable exception.

That would be great.  Otherwise, at the level of a using requests as a library for another application, I think we're forced into [something like](https://github.com/conda/conda/pull/6205/files)

```python
except AttributeError as e:
    if text_type(e) == "'NoneType' object has no attribute 'startswith'":
        raise ProxyError()
    else:
        raise
```