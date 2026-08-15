There are (at least) two issues here. First, it's str printer rendering Inverse as `^-1`. Compare
```
>>> A = MatrixSymbol('A', 2, 2)
>>> A**(-3)
A**(-3)
>>> A**(-1)
A^-1
```

Second, it's the fact that NumPy printer does not render Inverse as `np.linalg.inv` (and other powers as `np.linalg.matrix_power`). I tried to fix that (so far, for inverses)...

```diff
--- a/sympy/printing/pycode.py
+++ b/sympy/printing/pycode.py
@@ -495,6 +495,11 @@ def _print_seq(self, seq):
         delimite.get('delimiter', ', ')
         return '({},)'.format(delimiter.join(self._print(item) for item in seq))
 
+    def _print_Inverse(self, expr):
+        "Matrix inverse printer"
+        return '{0}({1})'.format(self._module_format('numpy.linalg.inv'),
+            self._print(expr.args[0]))
+
     def _print_MatMul(self, expr):
         "Matrix multiplication printer"
         return '({0})'.format(').dot('.join(self._print(i) for i in expr.args))
diff --git a/sympy/printing/str.py b/sympy/printing/str.py
index dc0d524f3..89d8b761b 100644
--- a/sympy/printing/str.py
+++ b/sympy/printing/str.py
@@ -209,7 +209,7 @@ def _print_AccumulationBounds(self, i):
                                         self._print(i.max))
 
     def _print_Inverse(self, I):
-        return "%s^-1" % self.parenthesize(I.arg, PRECEDENCE["Pow"])
+        return "%s**(-1)" % self.parenthesize(I.arg, PRECEDENCE["Pow"])
```

Oddly, with these changes `lambdify` generates
```
    def _lambdifygenerated(X0):
        return (inv(X0))
```
which throws "`inv` is undefined".  I ran out of energy trying to track down the reason for this. 