This can be fixed with something like:
```diff
diff --git a/sympy/printing/latex.py b/sympy/printing/latex.py
index debc81ca8d..5bf0cff782 100644
--- a/sympy/printing/latex.py
+++ b/sympy/printing/latex.py
@@ -2422,11 +2422,15 @@ def _print_DMF(self, p):
     def _print_Object(self, object):
         return self._print(Symbol(object.name))
 
-    def _print_LambertW(self, expr):
+    def _print_LambertW(self, expr, exp=None):
+        arg0 = self._print(expr.args[0])
+        exp = r'^{%s}' % (exp,) if exp is not None else ''
         if len(expr.args) == 1:
-            return r"W\left(%s\right)" % self._print(expr.args[0])
-        return r"W_{%s}\left(%s\right)" % \
-            (self._print(expr.args[1]), self._print(expr.args[0]))
+            result = r"W%s\left(%s\right)" % (exp, arg0)
+        else:
+            arg1 = self._print(expr.args[1])
+            result = r"W_{%s}%s\left(%s\right)" % (exp, arg0, arg1)
+        return result
 
     def _print_Morphism(self, morphism):
         domain = self._print(morphism.domain)
```
Hi Can I get to solve this problem I am a new contributor. Can you guide me for the same.

> This can be fixed with something like:

I have made the changes suggested by @oscarbenjamin. Is there anything else that needs to be done? 
