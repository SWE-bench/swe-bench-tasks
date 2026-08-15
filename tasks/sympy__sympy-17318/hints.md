@smichr The issue no longer exists. The above statement now gives the correct answer i.e., `I` which seems correct to me. But if there is anything to be corrected, I would like work on it.
This now gives the correct answer:
```julia
In [31]: sqrtdenest((3 - sqrt(2)*sqrt(4 + 3*I) + 3*I)/2)                                                                                                      
Out[31]: ⅈ
```

However it does so because the expression auto-evaluates before sqrtdenest has a change to look at it:
```julia
In [32]: ((3 - sqrt(2)*sqrt(4 + 3*I) + 3*I)/2)                                                                                                                
Out[32]: ⅈ
```

@smichr is this issue still valid?
> it does so because the expression auto-evaluates

That's a helpful observation about why it works, thanks.

Changing the expression to `sqrtdenest(3 - sqrt(2)*sqrt(4 + I) + 3*I)` raises the same error in current master.
I think this should fix it:
```
diff --git a/sympy/simplify/sqrtdenest.py b/sympy/simplify/sqrtdenest.py
index f0b7653ea..e437987d8 100644
--- a/sympy/simplify/sqrtdenest.py
+++ b/sympy/simplify/sqrtdenest.py
@@ -156,7 +156,8 @@ def _sqrt_match(p):
         res = (p, S.Zero, S.Zero)
     elif p.is_Add:
         pargs = sorted(p.args, key=default_sort_key)
-        if all((x**2).is_Rational for x in pargs):
+        sqargs = [x**2 for x in pargs]
+        if all(sq.is_Rational and sq.is_positive for sq in sqargs):
             r, b, a = split_surds(p)
             res = a, b, r
             return list(res)
```
The IndexError is raised in [`_split_gcd`](https://github.com/sympy/sympy/blob/1d3327b8e90a186df6972991963a5ae87053259d/sympy/simplify/radsimp.py#L1103) which is a helper that is only used in [`split_surds`](https://github.com/sympy/sympy/blob/1d3327b8e90a186df6972991963a5ae87053259d/sympy/simplify/radsimp.py#L1062). As far as I can tell `split_surds` is designed to split a sum of multiple addends that are all regular non-complex square roots. However in the example given by @smichr, `split_surds` is called by [`_sqrt_match`](https://github.com/sympy/sympy/blob/1d3327b8e90a186df6972991963a5ae87053259d/sympy/simplify/sqrtdenest.py#L140) with an argument of `4+I`, which leads to an empty `surds` list [here](https://github.com/sympy/sympy/blob/1d3327b8e90a186df6972991963a5ae87053259d/sympy/simplify/radsimp.py#L1078). This is completely unexpected by `_split_gcd`.

While `_split_gcd` and `split_surds` could potentially be "hardened" against misuse, I'd say `_sqrt_match` should simply avoid calling `split_surds` with bogus arguments. With the above change a call to `_sqrt_match` with argument `4+I` (or similar) will return an empty list `[]`: The `all((x**2).is_Rational)` case will be skipped and the maximum nesting depth of such a rather trivial argument being 0, an empty list is returned by [this line](https://github.com/sympy/sympy/blob/1d3327b8e90a186df6972991963a5ae87053259d/sympy/simplify/sqrtdenest.py#L168). An empty list is also returned for other cases where the expression simply doesn't match `a+b*sqrt(r)`. So that should indeed be the correct return value. (Note that `_sqrt_match` is also called by the symbolic denester, so `_sqrt_match` _must_ be able to handle more diverse input expressions.)

The proposed change has no incidence on the results of a default `test()` run.
Upon further inspection, I noticed that `split_surds` is also used in the user-facing function `rad_rationalize`. This function is also affected:
```
>>> from sympy.simplify.radsimp import rad_rationalize
>>> rad_rationalize(1,sqrt(2)+I)
(√2 - ⅈ, 3)
>>> rad_rationalize(1,4+I)
Traceback (most recent call last):
  File "/usr/lib/python3.6/code.py", line 91, in runcode
    exec(code, self.locals)
  File "<console>", line 1, in <module>
  File "/root/sympy/sympy/simplify/radsimp.py", line 935, in rad_rationalize
    g, a, b = split_surds(den)
  File "/root/sympy/sympy/simplify/radsimp.py", line 1080, in split_surds
    g, b1, b2 = _split_gcd(*surds)
  File "/root/sympy/sympy/simplify/radsimp.py", line 1116, in _split_gcd
    g = a[0]
IndexError: tuple index out of range
```
Since `rad_rationalize` is part of the user documentation, it shouldn't fail like this. So I'd say that, after all, it's `split_surds` that needs an additional check.
oh, and the following currently leads to an infinite recursion due to missing checks:
```
>>> from sympy.simplify.radsimp import rad_rationalize
>>> rad_rationalize(1,1+cbrt(2))
```
Please do not add bare except statements. We should find the source of this issue and fix it there.