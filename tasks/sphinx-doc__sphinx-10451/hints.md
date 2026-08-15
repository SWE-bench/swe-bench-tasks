I noticed this docstring causes warnings because `*` and `**` are considered as mark-up symbols:

```
    def __init__(self, x: int, *args: int, **kwargs: int) -> None:
        """Init docstring.

        :param x: Some integer
        :param *args: Some integer
        :param **kwargs: Some integer
        """
```

Here are warnings:
```
/Users/tkomiya/work/tmp/doc/example.py:docstring of example.ClassWithDocumentedInitAndStarArgs:6: WARNING: Inline emphasis start-string without end-string.
/Users/tkomiya/work/tmp/doc/example.py:docstring of example.ClassWithDocumentedInitAndStarArgs:7: WARNING: Inline strong start-string without end-string.
```

It will work fine if we escape `*` character like the following. But it's not officially recommended way, I believe.

```
    def __init__(self, x: int, *args: int, **kwargs: int) -> None:
        """Init docstring.

        :param x: Some integer
        :param \*args: Some integer
        :param \*\*kwargs: Some integer
        """
```

I'm not sure this feature is really needed?
> I noticed this docstring causes warnings because `*` and `**` are considered as mark-up symbols:
> 
> ```
>     def __init__(self, x: int, *args: int, **kwargs: int) -> None:
>         """Init docstring.
> 
>         :param x: Some integer
>         :param *args: Some integer
>         :param **kwargs: Some integer
>         """
> ```
> 
> Here are warnings:
> 
> ```
> /Users/tkomiya/work/tmp/doc/example.py:docstring of example.ClassWithDocumentedInitAndStarArgs:6: WARNING: Inline emphasis start-string without end-string.
> /Users/tkomiya/work/tmp/doc/example.py:docstring of example.ClassWithDocumentedInitAndStarArgs:7: WARNING: Inline strong start-string without end-string.
> ```
> 
> It will work fine if we escape `*` character like the following. But it's not officially recommended way, I believe.
> 
> ```
>     def __init__(self, x: int, *args: int, **kwargs: int) -> None:
>         """Init docstring.
> 
>         :param x: Some integer
>         :param \*args: Some integer
>         :param \*\*kwargs: Some integer
>         """
> ```
> 
> I'm not sure this feature is really needed?

This is needed for the Numpy and Google docstring formats, which napoleon converts to `:param:`s.

Oh, I missed numpydoc format. Indeed, it recommends prepending stars.
https://numpydoc.readthedocs.io/en/latest/format.html#parameters