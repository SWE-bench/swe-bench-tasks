Duplicated with #9195? Closing.
Oh, sorry. I understood these are different topic. Reopened now.
The issue seems to be stemming from https://github.com/sphinx-doc/sphinx/blob/80fbbb8462f075644e229c9d00293d4afde7adf2/sphinx/ext/autodoc/typehints.py#L33 -- since the types coming from typing are "stringified" and not being passed through intersphinx.
I guess the fix here is to pass these through `typing.restify` instead?
>I guess the fix here is to pass these through typing.restify instead?

No, it will generate incorrect mark-ups:

```
.. py:function:: func(x: :py:class:`Literal`\["a", "b"], y: :py:class:`int`)
```
