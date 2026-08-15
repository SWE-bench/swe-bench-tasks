Here's a place where the presence of the non-symbol generator creates problems: checking of the solution to the following equation:

```
>>> eq=737280.0*exp(-t)**24 - 576000.0*exp(-t)**15 + 46080.0*exp(-t)**6
>>> var('t', real=1);sol=solve(eq)
t
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "sympy\solvers\solvers.py", line 909, in solve
    solution = _solve(f[0], *symbols, **flags)
  File "sympy\solvers\solvers.py", line 1427, in _solve
    for den in dens)]
  File "sympy\solvers\solvers.py", line 1427, in <genexpr>
    for den in dens)]
  File "sympy\solvers\solvers.py", line 290, in checksol
    return bool(abs(val.n(18).n(12, chop=True)) < 1e-9)
  File "sympy\core\evalf.py", line 1331, in evalf
    result = evalf(self, prec + 4, options)
  File "sympy\core\evalf.py", line 1225, in evalf
    r = rf(x, prec, options)
  File "sympy\core\evalf.py", line 620, in evalf_pow
    re, im, re_acc, im_acc = evalf(base, prec + 5, options)
  File "sympy\core\evalf.py", line 1231, in evalf
    re, im = x._eval_evalf(prec).as_real_imag()
  File "sympy\polys\rootoftools.py", line 557, in _eval_evalf
    root = findroot(func, x0)
  File "sympy\mpmath\calculus\optimization.py", line 931, in findroot
    fx = f(x0[0])
  File "<string>", line 1, in <lambda>
  File "sympy\core\expr.py", line 225, in __float__
    raise TypeError("can't convert expression to float")
TypeError: can't convert expression to float
```

`solve` may have worked a way around this but the issue still remains.
```python
>>> RootOf(x**3+x-1, 0).poly.gen
x
>>> RootOf(sin(x)**3+sin(x)-1, 0)
CRootOf(x**3 + x - 1, 0)
```
RootOf represents a number, so it's proper to hash the above as the same. But from a user perspective one has to realize that it doesn't represent a solution for `x` unless `x` is a symbol.
```
>>> RootOf(sin(x)-1,0)  # sin(x) == 1 so x = (2*i+1)*pi/2
1
```
Perhaps the safest solution is to disallow anything but a symbol to be the generator.
>  the safest solution is to disallow anything but a symbol to be the generator.

+1