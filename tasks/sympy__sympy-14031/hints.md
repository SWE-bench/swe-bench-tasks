@normalhuman  I tried on the sympy 1.0 which is on [live](http://live.sympy.org) console of sympy and that was not throwing an error for this particular expression
That's interesting, thanks. SymPy 1.1.1 throws that exception, however, as does the current master branch. 
The immediate reason for failure, inability to coerce E to a field element, is easy to fix:
```diff
diff --git a/sympy/polys/fields.py b/sympy/polys/fields.py
index 9f9fdb4..9338be5 100644
--- a/sympy/polys/fields.py
+++ b/sympy/polys/fields.py
@@ -7,6 +7,8 @@
 from sympy.core.compatibility import is_sequence, reduce, string_types
 from sympy.core.expr import Expr
 from sympy.core.mod import Mod
+from sympy.core.numbers import Exp1
+from sympy.core.singleton import S
 from sympy.core.symbol import Symbol
 from sympy.core.sympify import CantSympify, sympify
 from sympy.functions.elementary.exponential import ExpBase
@@ -218,7 +220,7 @@ def _rebuild(expr):
                 return reduce(add, list(map(_rebuild, expr.args)))
             elif expr.is_Mul:
                 return reduce(mul, list(map(_rebuild, expr.args)))
-            elif expr.is_Pow or isinstance(expr, ExpBase):
+            elif expr.is_Pow or isinstance(expr, (ExpBase, Exp1)):
                 b, e = expr.as_base_exp()
                 # look for bg**eg whose integer power may be b**e
                 choices = tuple((gen, bg, eg) for gen, (bg, eg) in powers
@@ -226,8 +228,8 @@ def _rebuild(expr):
                 if choices:
                     gen, bg, eg = choices[0]
                     return mapping.get(gen)**(e/eg)
-                elif e.is_Integer:
-                    return _rebuild(expr.base)**int(expr.exp)
+                elif e.is_Integer and e is not S.One:
+                    return _rebuild(b)**e
``` 
So, now E is understood to be an element of Z(exp(1/2)). However, there is another error, coming from     `gmpy_gcd(a, b)` getting Integer types instead of expected 'mpz' type, and I don't see why that is happening. 