It is an `Add.flatten` issue:
```diff
diff --git a/sympy/core/add.py b/sympy/core/add.py
index 38ab6cd..d87816b 100644
--- a/sympy/core/add.py
+++ b/sympy/core/add.py
@@ -139,8 +139,8 @@ def flatten(cls, seq):
                         o.is_finite is False) and not extra:
                     # we know for sure the result will be nan
                     return [S.NaN], [], None
-                if coeff.is_Number:
-                    coeff += o
+                if coeff.is_Number or isinstance(coeff, AccumBounds):
+                    coeff = coeff + o if coeff.is_Number else coeff.__add__(o)
                     if coeff is S.NaN and not extra:
                         # we know for sure the result will be nan
                         return [S.NaN], [], None
```
The following fails in master:
```python                         
>>> Add(*[oo, AccumBounds(-1, 1)])
oo
>>> Add(*list(reversed([oo, AccumBounds(-1, 1)])))
oo
```