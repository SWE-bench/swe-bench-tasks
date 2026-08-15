Yes, I think adding `if k.is_zero or (n.is_nonnegative and d.is_zero)` should fix this.
Similar issue would be `binomial(n, n - 1)` for same assumptions on `n`.
And it could be fixed using `if (k - 1).is_zero or (n.is_nonnegative and (d - 1).is_zero)`.

Both the cases, will hold even if n is not an integer. So, tests with minimal assumptions would be:
```
In []: n = Symbol('n', nonnegative=True)
In []: binomial(n, n)
Out[]: 1
In []: binomial(n, n - 1)
Out[]: n
```
Though it should be checked that it doesn't break any case.