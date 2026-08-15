TRmorrie is ignoring the power on the `cos(g)` factor. The fix might be
```diff
diff --git a/sympy/simplify/fu.py b/sympy/simplify/fu.py
index 7fce72d38a..b9f0e39a75 100644
--- a/sympy/simplify/fu.py
+++ b/sympy/simplify/fu.py
@@ -1206,8 +1206,8 @@ def f(rv, first=True):
                             c.remove(cc)
                     new.append(newarg**take)
                 else:
-                    no.append(c.pop(0))
-            c[:] = no
+                    b = cos(c.pop()*a)
+                    other.append(b**coss[b])

         if new:
             rv = Mul(*(new + other + [
```


TRmorrie is ignoring the power on the `cos(g)` factor. The fix might be
```diff
diff --git a/sympy/simplify/fu.py b/sympy/simplify/fu.py
index 7fce72d38a..b9f0e39a75 100644
--- a/sympy/simplify/fu.py
+++ b/sympy/simplify/fu.py
@@ -1206,8 +1206,8 @@ def f(rv, first=True):
                             c.remove(cc)
                     new.append(newarg**take)
                 else:
-                    no.append(c.pop(0))
-            c[:] = no
+                    b = cos(c.pop()*a)
+                    other.append(b**coss[b])

         if new:
             rv = Mul(*(new + other + [
```

