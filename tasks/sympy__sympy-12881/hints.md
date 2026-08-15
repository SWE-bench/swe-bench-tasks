```diff
diff --git a/sympy/polys/polytools.py b/sympy/polys/polytools.py
index 9c12741..92e7ca6 100644
--- a/sympy/polys/polytools.py
+++ b/sympy/polys/polytools.py
@@ -255,7 +255,7 @@ def free_symbols(self):
         ========
 
         >>> from sympy import Poly
-        >>> from sympy.abc import x, y
+        >>> from sympy.abc import x, y, z
 
         >>> Poly(x**2 + 1).free_symbols
         {x}
@@ -263,12 +263,17 @@ def free_symbols(self):
         {x, y}
         >>> Poly(x**2 + y, x).free_symbols
         {x, y}
+        >>> Poly(x**2 + y, x, z).free_symbols
+        {x, y}
 
         """
-        symbols = set([])
-
-        for gen in self.gens:
-            symbols |= gen.free_symbols
+        symbols = set()
+        gens = self.gens
+        for i in range(len(gens)):
+            for monom in self.monoms():
+                if monom[i]:
+                    symbols |= gens[i].free_symbols
+                    break
 
         return symbols | self.free_symbols_in_domain
 
diff --git a/sympy/polys/tests/test_polytools.py b/sympy/polys/tests/test_polytools.py
index a1e5179..8e30ef1 100644
--- a/sympy/polys/tests/test_polytools.py
+++ b/sympy/polys/tests/test_polytools.py
@@ -468,6 +468,8 @@ def test_Poly_free_symbols():
     assert Poly(x**2 + sin(y*z)).free_symbols == {x, y, z}
     assert Poly(x**2 + sin(y*z), x).free_symbols == {x, y, z}
     assert Poly(x**2 + sin(y*z), x, domain=EX).free_symbols == {x, y, z}
+    assert Poly(1 + x + x**2, x, y, z).free_symbols == {x}
+    assert Poly(x + sin(y), z).free_symbols == {x, y}
 
 
 def test_PurePoly_free_symbols():

```