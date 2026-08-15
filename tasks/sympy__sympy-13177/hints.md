Even if `p.base` is an integer, the exponent must also be positive.

```
if (p == q or p == -q or p.is_integer and q == 1 or
        p.base == q and q.is_integer and p.is_Pow and p.exp.is_Integer
        and p.exp.is_positive):
    return S.Zero
```

because

```
>>> 2**-2 % S(2)
1/4
```
I would like to work on this. 
One would need just a slight change in the order of the properties, 


            p.is_Pow and p.base == q and q.is_integer and p.exp.is_Integer
            and p.exp.is_positive):
            return S.Zero

instead of

        p.base == q and q.is_integer and p.is_Pow and p.exp.is_Integer
        and p.exp.is_positive):
        return S.Zero


otherwise one gets an Attribute error:'Symbol' object has no attribute 'base' from
>>> Mod(x**2, x).
