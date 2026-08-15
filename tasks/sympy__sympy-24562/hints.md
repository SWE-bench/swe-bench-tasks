This should probably raise an error. The expected way to do this is:
```python
In [1]: Rational('0.5/100')
Out[1]: 1/200

In [2]: Rational('0.5') / Rational('100')
Out[2]: 1/200
```
Actually, this should be a flaw in the logic because string is multiplied somewhere in 
https://github.com/sympy/sympy/blob/68803e50d9d76a8b14eaf2a537f90cb86d0a87be/sympy/core/numbers.py#L1628-L1640
The logic should like like this:
```python
        Q = 1
        gcd = 1

        if not isinstance(p, SYMPY_INTS):
            p = Rational(p)
            Q *= p.q
            p = p.p
        else:
            p = int(p)

        if not isinstance(q, SYMPY_INTS):
            q = Rational(q)
            p *= q.q
            Q *= q.p
        else:
            Q *= int(q)
        q = Q
```
A test can be added:
```python
for p in ('1.5', 1.5, 2):
    for q in ('1.5', 1.5, 2):
        assert Rational(p, q).as_numer_denom() == Rational('%s/%s'%(p,q)).as_numer_denom()
```