Seems due to the use of `Q`, only `P` is handled in the diff code. This:
```
--- astropy/io/fits/diff.py
+++ astropy/io/fits/diff.py
@@ -1449,7 +1449,7 @@ class TableDataDiff(_BaseDiff):
                 arrb.dtype, np.floating
             ):
                 diffs = where_not_allclose(arra, arrb, rtol=self.rtol, atol=self.atol)
-            elif "P" in col.format:
+            elif "P" in col.format or "Q" in col.format:
                 diffs = (
                     [
                         idx
```
seems to work, but would need some tests etc. Do you want to work on a fix ?
I'm not particularly familiar with `FITSDiff` I'd rather not handle the PR.