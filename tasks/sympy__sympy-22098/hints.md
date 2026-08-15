I can confirm this in 1.7 and also in previous versions so this is not a new bug.

It also happens with `sqrt(4)`:
```python
In [1]: sqrt(4, evaluate=False)                                                                                                   
Out[1]: √4

In [2]: parse_expr("sqrt(4)", evaluate=False)                                                                                     
Out[2]: 2
```

I think maybe it happens with all functions:
```python
In [5]: parse_expr("exp(0)", evaluate=False)                                                                                      
Out[5]: 1

In [6]: exp(0, evaluate=False)                                                                                                    
Out[6]: 
 0
ℯ 
```

It looks like the evaluatefalse method only works for a few basic operators:
https://github.com/sympy/sympy/blob/e5c901e5f30bcc9bd0cb91f03d0696815b96bd1a/sympy/parsing/sympy_parser.py#L1021-L1031
@oscarbenjamin Thanks for the quick reply! 

How come that:

```python
>>> sympy.parse_expr("sin(12/6)", evaluate=False)
sin(12/6)
```

As there is no custom `ast.Name` visitor on `EvaluateFalseTransformer` I'd expect that it yields  `sin(2)` as in case for sqrt

```python
>>> sympy.parse_expr("sqrt(12/6)", evaluate=False)
sqrt(2)
```



I think that when a `Pow` evaluates it forces the evaluation of its args.
I encounted similar problems w/ Matrix values, outside of parsing:

```
$ python
Python 3.9.1 (default, Jan 20 2021, 00:00:00) 
[GCC 10.2.1 20201125 (Red Hat 10.2.1-9)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> from sympy import *
>>> from sympy import __version__
>>> __version__
'1.7.1'

>>> Mul(3, 4, evaluate=False)  # As expected, multiply is not evaluated.
3*4

>>> Mul(3, Matrix([[4]]), evaluate=False)  # Multiply is unexpectedly evaluated.
Matrix([[12]])
```

This problem does not occur with `Add`:

```
>>> Add(3, 4, evaluate=False)
3 + 4

>>> Add(3, Matrix([[4]]), evaluate=False)
3 + Matrix([[4]])
```
> I encounted similar problems w/ Matrix values, outside of parsing:

That's a different problem