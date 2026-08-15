FYI, here is a fix that seems to work. If anyone else wants to put this (or some variation) into a PR and add a test etc then feel free!
```diff
(astropy) ➜  astropy git:(main) ✗ git diff
diff --git a/astropy/table/table.py b/astropy/table/table.py
index d3bcaebeb5..6db399a7b8 100644
--- a/astropy/table/table.py
+++ b/astropy/table/table.py
@@ -1072,7 +1072,11 @@ class Table:
         Coercion to a different dtype via np.array(table, dtype) is not
         supported and will raise a ValueError.
         """
-        if dtype is not None:
+        if np.dtype(dtype).kind == 'O':
+            out = np.array(None, dtype=object)
+            out[()] = self
+            return out
+        elif dtype is not None:
             raise ValueError('Datatype coercion is not allowed')
 
         # This limitation is because of the following unexpected result that
```
