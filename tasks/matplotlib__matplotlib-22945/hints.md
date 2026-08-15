Okay the minimal example wasn't so bad, updated top comment.
Argh actually on main `git revert f93a0fc251f7aa0a8da71f92e97e54faa25b8cd7` (f93a0fc251f7aa0a8da71f92e97e54faa25b8cd7) seems to fix it, not `git revert 396a010`. Apparently I am bad at `git bisect`. So maybe it's actually #22476?
I can confirm it started failing in f93a0fc251f7aa0a8da71f92e97e54faa25b8cd7.
I think this ultimately stems from removing `offsetsNone` back in https://github.com/matplotlib/matplotlib/pull/20717
We need some way of tracking that the (0, 0) case was actually passed in and desired, or if that is just the default (0, 0) from initialization. Seems like adding that flag (maybe renaming it too) is the quick fix?

```diff --git a/lib/matplotlib/collections.py b/lib/matplotlib/collections.py
index 49485bd900..0a62cd49e4 100644
--- a/lib/matplotlib/collections.py
+++ b/lib/matplotlib/collections.py
@@ -195,8 +195,9 @@ class Collection(artist.Artist, cm.ScalarMappable):
 
         # default to zeros
         self._offsets = np.zeros((1, 2))
+        self._has_offsets = offsets is not None
 
-        if offsets is not None:
+        if self._has_offsets:
             offsets = np.asanyarray(offsets, float)
             # Broadcast (2,) -> (1, 2) but nothing else.
             if offsets.shape == (2,):
@@ -290,18 +291,19 @@ class Collection(artist.Artist, cm.ScalarMappable):
                     offset_trf.transform_non_affine(offsets),
                     offset_trf.get_affine().frozen())
 
-            # this is for collections that have their paths (shapes)
-            # in physical, axes-relative, or figure-relative units
-            # (i.e. like scatter). We can't uniquely set limits based on
-            # those shapes, so we just set the limits based on their
-            # location.
-            offsets = (offset_trf - transData).transform(offsets)
-            # note A-B means A B^{-1}
-            offsets = np.ma.masked_invalid(offsets)
-            if not offsets.mask.all():
-                bbox = transforms.Bbox.null()
-                bbox.update_from_data_xy(offsets)
-                return bbox
+            if self._has_offsets:
+                # this is for collections that have their paths (shapes)
+                # in physical, axes-relative, or figure-relative units
+                # (i.e. like scatter). We can't uniquely set limits based on
+                # those shapes, so we just set the limits based on their
+                # location.
+                offsets = (offset_trf - transData).transform(offsets)
+                # note A-B means A B^{-1}
+                offsets = np.ma.masked_invalid(offsets)
+                if not offsets.mask.all():
+                    bbox = transforms.Bbox.null()
+                    bbox.update_from_data_xy(offsets)
+                    return bbox
         return transforms.Bbox.null()
 
     def get_window_extent(self, renderer):
```