From [the docs](http://www.sphinx-doc.org/en/stable/domains.html#info-field-lists):
> Multiple types in a type field will be linked automatically if separated by the word “or”:

So this feature is already available using this syntax:

```python
def foo(foo):
    """
    Bla blu

    :type foo: str or int or None
    """
```

Instead of multiplying the possible syntaxes for this, why don't we try to adhere to [PEP 484](https://www.python.org/dev/peps/pep-0484/#union-types) and the [`typing` module](https://docs.python.org/3/library/typing.html#typing.Union)? These are already Python standards that are readily available in modern Python releases. I wouldn't take PyCharm as a reference for this kind of stuff, as they seem to enjoy never following the community's common practices.

```python
def foo(foo):
    """
    Bla blu

    :type foo: Union[str, int, None]
    """
```
A lot of time has passed since I filed this issue. I don't remember whether I specifically wanted the pipe syntax or whether it was just an example... I certainly didn't know about that PEP and that module didn't exist at that time as far as I know... As well as the paragraph in the documentation that you have mentioned... And that PyCharm's syntax was, for sure, the only syntax I knew... Maybe it was a mistake to suggest a particular implementation...

Now, it's enough for me that there is a support for union types in Sphinx already...