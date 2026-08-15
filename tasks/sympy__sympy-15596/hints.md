I think that it could fail in the same way as `Poly` does when the generator is given:
```
>>> Poly((x-2)/(x**2+1), x)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "sympy/polys/polytools.py", line 129, in __new__
    return cls._from_expr(rep, opt)
  File "sympy/polys/polytools.py", line 239, in _from_expr
    rep, opt = _dict_from_expr(rep, opt)
  File "sympy/polys/polyutils.py", line 366, in _dict_from_expr
    rep, gens = _dict_from_expr_if_gens(expr, opt)
  File "sympy/polys/polyutils.py", line 305, in _dict_from_expr_if_gens
    (poly,), gens = _parallel_dict_from_expr_if_gens((expr,), opt)
  File "sympy/polys/polyutils.py", line 215, in _parallel_dict_from_expr_if_gens
    "the set of generators." % factor)
sympy.polys.polyerrors.PolynomialError: 1/(x**2 + 1) contains an element of the set of generators.
```
(`gen` could be added [here](https://github.com/sympy/sympy/blob/master/sympy/polys/polytools.py#L4454) if it is given.)