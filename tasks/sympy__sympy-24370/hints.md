The fix seems to be
```diff
diff --git a/sympy/core/numbers.py b/sympy/core/numbers.py
index 3b1aec2..52f7ea4 100644
--- a/sympy/core/numbers.py
+++ b/sympy/core/numbers.py
@@ -2423,7 +2423,7 @@ def __floordiv__(self, other):
             return NotImplemented
         if isinstance(other, Integer):
             return Integer(self.p // other)
-        return Integer(divmod(self, other)[0])
+        return divmod(self, other)[0]
 
     def __rfloordiv__(self, other):
         return Integer(Integer(other).p // self.p)
```
The fix seems to be
```diff
diff --git a/sympy/core/numbers.py b/sympy/core/numbers.py
index 3b1aec2..52f7ea4 100644
--- a/sympy/core/numbers.py
+++ b/sympy/core/numbers.py
@@ -2423,7 +2423,7 @@ def __floordiv__(self, other):
             return NotImplemented
         if isinstance(other, Integer):
             return Integer(self.p // other)
-        return Integer(divmod(self, other)[0])
+        return divmod(self, other)[0]
 
     def __rfloordiv__(self, other):
         return Integer(Integer(other).p // self.p)
```