Can this please have a more descriptive title? 
It looks like `*args` used to fall through to `_process_projection_requirements` which used to use the `*args` as part of `_make_key` but that is now removed.

Naively adding a deprecation to passing extra args 

```diff
diff --git a/lib/matplotlib/figure.py b/lib/matplotlib/figure.py
index aac3d7270a..428bc4c18c 100644
--- a/lib/matplotlib/figure.py
+++ b/lib/matplotlib/figure.py
@@ -627,12 +627,17 @@ default: %(va)s
                 raise ValueError(
                     "The Axes must have been created in the present figure")
         else:
-            rect = args[0]
+            rect, *extra_args = args
             if not np.isfinite(rect).all():
                 raise ValueError('all entries in rect must be finite '
                                  f'not {rect}')
-            projection_class, pkw = self._process_projection_requirements(
-                *args, **kwargs)
+            projection_class, pkw = self._process_projection_requirements(**kwargs)
+            _api.warn_deprecated(
+                "3.8",
+                message="Passing more than one positional argument to Figure.add_axes is "
+                "deprecated and will raise in the future.  "
+                "Currently any additional positional arguments are ignored."
+                )
 
             # create the new axes using the axes class given
             a = projection_class(self, rect, **pkw)
@@ -762,8 +767,7 @@ default: %(va)s
             if (len(args) == 1 and isinstance(args[0], Integral)
                     and 100 <= args[0] <= 999):
                 args = tuple(map(int, str(args[0])))
-            projection_class, pkw = self._process_projection_requirements(
-                *args, **kwargs)
+            projection_class, pkw = self._process_projection_requirements(**kwargs)
             ax = projection_class(self, *args, **pkw)
             key = (projection_class, pkw)
         return self._add_axes_internal(ax, key)
@@ -1663,7 +1667,7 @@ default: %(va)s
         return None
 
     def _process_projection_requirements(
-            self, *args, axes_class=None, polar=False, projection=None,
+            self, axes_class=None, polar=False, projection=None,
             **kwargs):
         """
         Handle the args/kwargs to add_axes/add_subplot/gca, returning::

```

causes ~45 failures as we get the warnings in the test suite.  