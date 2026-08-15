This is not related to overloaded constructors. Autodoc automatically fills return value annotation to the signature definitions in the docstring excluding the first entry unexpectedly. So I reproduced this with this class:
```
class Foo:
    """Foo()
    Foo(x: int)
    Foo(x: int, y: int)

    docstring
    """
```

I agree this is not unexpected behavior. So I'll fix this soon.

Note: The example you given uses `autoclass_content = 'both'` option. Then autodoc refers the docstring of `MyComplex.__init__()` method too.