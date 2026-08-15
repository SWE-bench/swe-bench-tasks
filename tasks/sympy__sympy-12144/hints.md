I can confirm this.  Quoting `printing/repr.py`

> srepr returns a string so that the relation eval(srepr(expr))=expr holds in an appropriate environment.

Here's my minimal example:

```
>>> d = Dummy('d')
>>> A = Add(d, d, evaluate=False)

>>> srepr(A)                    # can see what the problem will be
"Add(Dummy('d'), Dummy('d'))"

>>> B = S(srepr(A))
>>> B
_d + _d

>>> A.doit()
2*_d

>>> B.doit()     # cannot, has two different Dummys
_d + _d
```

Note that Dummy does seem to maintain its identity across pickling:

```
>>> import cPickle
>>> d1 = Dummy()
>>> s1 = cPickle.dumps(d1)
>>> d2 = cPickle.loads(s1)
>>> d1 == d2
True
>>> d1 is d2
False
```
