I don't think that set notations are supported in piecewise yet.
I think this particular error might be trivial to fix by adding Contains.as_set as in:
```
>>> Contains(x, S.Integers).as_set()
S.Integers
```
> Contains(x, S.Integers).as_set()
> S.Integers

I tried it but the following happens,
```python
Traceback (most recent call last):
  File "/home/gagandeep/sympy_debug.py", line 593, in <module>
    p2 = Piecewise((S(1), cond), (S(0), True))
  File "/home/gagandeep/sympy/sympy/functions/elementary/piecewise.py", line 143, in __new__
    r = cls.eval(*newargs)
  File "/home/gagandeep/sympy/sympy/functions/elementary/piecewise.py", line 192, in eval
    c = c.as_set().as_relational(x)
AttributeError: 'Range' object has no attribute 'as_relational'
```