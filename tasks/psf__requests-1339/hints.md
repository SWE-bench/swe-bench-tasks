The same issue arises when initializing a CaseInsensitiveDict using a dictionary of differing-case keys or differing-case keyword arguments. Example:

```
>>> from requests.structures import CaseInsensitiveDict
>>> CaseInsensitiveDict(a=1, A=2, B=3)
{'A': 2, 'a': 1, 'B': 3}
>>> CaseInsensitiveDict({'a': 1, 'A': 2, 'B': 3})
{'A': 2, 'a': 1, 'B': 3}
```

I'm not sure what the best approach is to addressing this issue, since we are going to run into problems with Cookie and Set-Cookie headers.  The first, sends cookies in a semi-colon delimited fashion, whereas the latter sends a unique header for each cookie being set. In the case of Set-Cookie, some clients (such as Firefox) do not parse headers whose values were combined with a comma as delimiter as suggested in http://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.2. Though neither does `Cookie.SimpleCookie`:

```
>>> SimpleCookie('Set-Cookie: a=1; b=2')['a']
<Morsel: a='1'>
>>> SimpleCookie('Set-Cookie: a=1; b=2')['b'] 
<Morsel: b='2'>
>>> SimpleCookie('Set-Cookie: a=1, b=2')['a'] # incorrect?
<Morsel: a='1,'>
>>> SimpleCookie('Set-Cookie: a=1, b=2')['b']
<Morsel: b='2'>
>>> SimpleCookie('Set-Cookie: a=1 b=2')['a'] 
<Morsel: a='1'>
>>> SimpleCookie('Set-Cookie: a=1 b=2')['b']
<Morsel: b='2'>
```

urllib3 combines headers with a comma as well: https://github.com/shazow/urllib3/blob/master/urllib3/response.py#L174

Since the CaseInsensitiveDict is used as a container for HTTP headers, would it make more sense to change values to be lists instead of strings?

We should fix this.

I've submitted a pull request to address this issue. Behavior when initializing a case-insensitive dict with differing-case keys is undefined, as is the case when initializing a dict with multiple values for the same key.
