When using `sphinx.ext.napoleon`, the docstrings are assumed to follow either NumPy or Google docstrings. According to [[1]](#1) and [[2]](#2), docstrings used on attributes and placed *after* the attribute *may* specify their type first, followed by a colon, and then by whatever you want. In particular, if a colon is present, the LHS is treated as a type and the RHS as a regular text.

EDIT: after investigation, I confirm that this behaviour is a bug and not an expected behaviour.

~~In particular, your specific docstring does not comply with Google or NumPy docstrings, hence the failure. In particular, what you could request is a *feature* to allow docstrings placed after the documented object to *optionally* specify the type.~~ This, however, requires `GoogleDocstring._parse_attribute_docstring` and `GoogleDocstring._consume_inline_attribute` to be implemented differently (the work behind will not be trivial).

By the way, this does not affect dataclasses in general, but affects all members documented using post-docstrings together with the `sphinx.ext.napoleon` extension for which the first line contains a colon such that the content on its right is not a valid reST string.

---

<a id="1">[1]</a> https://www.sphinx-doc.org/en/master/usage/extensions/example_google.html#example-google
<a id="2">[2]</a> https://www.sphinx-doc.org/en/master/usage/extensions/example_numpy.html#example-numpy

> According to [[1]](https://github.com/sphinx-doc/sphinx/issues/11246#1) and [[2]](https://github.com/sphinx-doc/sphinx/issues/11246#2), docstrings used on attributes and placed after the attribute must specify their type first

Maybe I'm missing something here but I don't see where this says that these docstrings *must* specify their type. It says that they *may* do so, which is in line with how these are handled for arguments as well.

To quote the section you linked:

> The type may optionally be specified on the first line, separated by a colon.

But even following this supposed requirement, things still don't work as expected:

```python
module_level_variable2 = 98765
"""int: Module level variable documented inline. `link <https://example.org>`_"""
```

This is from the linked example, with only an external reference added. It results in the same error. 

You can make it even simpler:

```python
module_level_variable2 = 98765
"""int: Module level variable documented inline. This: is what breaks it"""
```

> what you could request is a feature to allow docstrings placed after the documented object to optionally specify the type

What I am requesting is that a colon in the first line of an attribute docstring does not result in a warning. 

> It says that they may do so, which is in line with how these are handled for arguments as well.

Yes, that's right. My bad ! Anyway, the issue is that "if there is a colon, then we assume that the LHS is the type, the RHS is the rest"

> You can make it even simpler:

Ok I confirmed this on my side. I'll edit my previous answer and try to work on that issue this afternoon then.


> Ok I confirmed this on my side. I'll edit my previous answer and try to work on that issue this afternoon then.

Cool, thanks for the quick turnaround! 
I cannot guarantee a quick fix because this requires to refactor the Google docstring parser, which I never touched. Also, allowing an *arbitrary* colon in the first line means that we cannot distinguish between the type and just a word suffixed by a colon.

For instance, how can we distinguish between:

```
'''blabla: blublu'''

'''int: blublu'
```

without knowing that `blabla` is *not* a type (and there is no way that we can know this at the level of the parser). One possibility is to first escape reST markup (e.g., links) before splitting on the colon (like, we still won't be able to fix the above issue but we could allow a link to be present). 

Actually, we could fix your "simpler" example by taking into account inline links in `sphinx.ext.napoleon.docstring._xref_or_code_regex`.


