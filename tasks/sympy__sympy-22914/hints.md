This can also be done by simply adding `min` and `max` to `_known_functions`:
```python
_known_functions = {
    'Abs': 'abs',
    'Min': 'min',
}
```

leading to 

```python
>>> from sympy import Min
>>> from sympy.abc import x, y
>>> from sympy.printing.pycode import PythonCodePrinter
>>> PythonCodePrinter().doprint(Min(x,y))
'min(x, y)'
```
@ThePauliPrinciple Shall I open a Pull request then with these changes that you mentioned here?

> @ThePauliPrinciple Shall I open a Pull request then with these changes that you mentioned here?

I'm not sure whether the OP (@yonizim ) intended to create a PR or only wanted to mention the issue, but if not, feel free to do so. 
Go ahead @AdvaitPote . Thanks for the fast response.
Sure @yonizim @ThePauliPrinciple !