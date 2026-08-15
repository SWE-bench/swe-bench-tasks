A non-python example, searching for `ciphertext` in [pyca/cryptography](https://github.com/pyca/cryptography), the glossary `ciphertext` term is pretty low on the page and hidden among mentions of it within autodoc pages.
There's also a bpo issue on that subject: https://bugs.python.org/issue42106

It provides more examples from the Python documentation

> For instance if you search "append": https://docs.python.org/3/search.html?q=append
>
> On my end, neither list nor MutableSequence appear anywhere on this page, even scrolling down.
>
> Searching for "list": https://docs.python.org/3/search.html?q=list
>
> The documentation for the builtin "list" object also doesn't appear on the page. [Data Structures](https://docs.python.org/3/tutorial/datastructures.html?highlight=list) and [built-in types](https://docs.python.org/3/library/stdtypes.html?highlight=list) appear below the fold and the former is genuinely useful but also very easy to miss (I had not actually noticed it before going back in order to get the various links and try to extensively describe the issue). Neither actually links to the `list` builtin type though.
>
> Above the fold we find various "list" methods and classes from the stdlib as well as the PDB `list` comment, none of which seems like the best match for the query.


This would also be useful for the core CPython documentation.

A
Yeah, as discussed, this would be extremely useful for the CPython docs, as brought up in python/cpython#60075 , python/cpython#89541 , python/cpython#86272,  python/cpython#86272 and probably others, so it would be fantastic if you could implement this. To be honest, it confuses me why the search index wouldn't include the...index...to begin with, heh.

I was going to offer to help, but I'm sure you'd do a far better job than I would. If you do need something within my (limited) skillset, like testing this or reviewing docs, etc, let me know. Thanks!