The first step to fixing this is to define a print method for `Mod` in `sympy/printing/fscode.py`. There is no `_print_Mod()` method.

You can see it not working here:

```
Python 3.5.5 | packaged by conda-forge | (default, Jul 23 2018, 23:45:43) 
Type 'copyright', 'credits' or 'license' for more information
IPython 6.5.0 -- An enhanced Interactive Python. Type '?' for help.

In [1]: from sympy import Mod

In [2]: from sympy.abc import x

In [3]: from sympy.printing import fcode

In [6]: fcode(Mod(x, 2))
Out[6]: '      Mod(1.0d0*x, 2.0d0)'

In [7]: fcode(x % 2)
Out[7]: '      Mod(1.0d0*x, 2.0d0)'

In [8]: x % 2
Out[8]: Mod(x, 2)
```