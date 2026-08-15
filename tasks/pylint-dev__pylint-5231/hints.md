With respect to `missing-return-type-doc`:
I think this is due to the fact that the section `Returns` is missing.
Perhaps this is allowed in `numpy` documentation and we should update this, but if you look at the docs you linked there is actually a section on return type annotation.
https://numpydoc.readthedocs.io/en/latest/format.html#returns

So this should work:
```python
def func(arg1: bool, arg2: bool):
    """Return args.

    Parameters
    ----------
    arg1 : bool
        arg1

    arg2
        arg2
     
    Returns
    ----------
    bool
    bool (?, the type is required for return type documentation)
    """
    return arg1, arg2
```

`missing-param-doc` seems to be a false positive indeed.
@DanielNoord, absolutely, apologises for confusing the issue. Do you want me to close and raise a new tidier version?

and thank you for the immediate response!
No worries. It is already really helpful to have some code that should reproduce the issue. No need to open a new one.

It is strange as I feel I have visited this part of the code recently and fixed something similar, but I can't find that PR. I will assign myself and investigate in the coming days!
Tremendous, thanks!

Might you have been looking at this [issue](https://github.com/PyCQA/pylint/issues/4035)? It was the only one I could find along simlar lines.
No, but I might as well look at that one at the same time 😄 
> No, but I might as well look at that one at the same time 😄

:smile: wow, two for the price of one! Thanks again!
With respect to `missing-return-type-doc`:
I think this is due to the fact that the section `Returns` is missing.
Perhaps this is allowed in `numpy` documentation and we should update this, but if you look at the docs you linked there is actually a section on return type annotation.
https://numpydoc.readthedocs.io/en/latest/format.html#returns

So this should work:
```python
def func(arg1: bool, arg2: bool):
    """Return args.

    Parameters
    ----------
    arg1 : bool
        arg1

    arg2
        arg2
     
    Returns
    ----------
    bool
    bool (?, the type is required for return type documentation)
    """
    return arg1, arg2
```

`missing-param-doc` seems to be a false positive indeed.
@DanielNoord, absolutely, apologises for confusing the issue. Do you want me to close and raise a new tidier version?

and thank you for the immediate response!
No worries. It is already really helpful to have some code that should reproduce the issue. No need to open a new one.

It is strange as I feel I have visited this part of the code recently and fixed something similar, but I can't find that PR. I will assign myself and investigate in the coming days!
Tremendous, thanks!

Might you have been looking at this [issue](https://github.com/PyCQA/pylint/issues/4035)? It was the only one I could find along simlar lines.
No, but I might as well look at that one at the same time 😄 
> No, but I might as well look at that one at the same time 😄

:smile: wow, two for the price of one! Thanks again!