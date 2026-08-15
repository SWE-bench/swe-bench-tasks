I agree the behavior is less than optimal.  Perhaps polar plots should just be created with 0 as explicit lower r-lim?  (I think negative r-lims should be explicitly requested.)
(And then #10101 could be reverted as unnecessary anymore.)
I think the issue here is the autoscaling is including a bit of the plot with `r<0`, I would guess because the markers overlap into that area. @dvincentwest if you want a workaround in the meantime using `scatter` instead of `plot` *might* work.
Unfortunately, I think right now there's no mechanism to disable autoscaling on one of the two bounds (r=0) while keeping it on the other (upper r bound) :/
Can it be handled in `projections.polar.RadialLocator.autoscale()`?
I doubt so.  In fact, Locator.autoscale() seems completely unused right now (since 5964da2, hey you wrote that :)).

(Aside re: autoscale(): it seems like it got superseded by view_limits() (for "round" autoscaling mode), except that dates.py has never been updated so date locators still define the unused autoscale() but don't define view_limits()?)

However, the use of sticky_edges in #13444 gave me another idea: we can slightly change the semantics of sticky edges to mean "an autoscale call cannot move a limit *beyond* a sticky edge through margins application" (including when the limit is already touching the sticky edge, which is the case in all use cases so far), then keep the sticky edge at zero and set the lower datalim to zero.
Looks like the following patch implements the strategy above (of slightly changing the semantics of sticky_edges to fix this issue):
```patch
diff --git i/lib/matplotlib/axes/_base.py w/lib/matplotlib/axes/_base.py
index 9515e03e5..8d02a0e68 100644
--- i/lib/matplotlib/axes/_base.py
+++ w/lib/matplotlib/axes/_base.py
@@ -2387,8 +2387,8 @@ class _AxesBase(martist.Artist):
                 (self._xmargin and scalex and self._autoscaleXon) or
                 (self._ymargin and scaley and self._autoscaleYon)):
             stickies = [artist.sticky_edges for artist in self.get_children()]
-            x_stickies = np.array([x for sticky in stickies for x in sticky.x])
-            y_stickies = np.array([y for sticky in stickies for y in sticky.y])
+            x_stickies = np.sort([x for sticky in stickies for x in sticky.x])
+            y_stickies = np.sort([y for sticky in stickies for y in sticky.y])
             if self.get_xscale().lower() == 'log':
                 x_stickies = x_stickies[x_stickies > 0]
             if self.get_yscale().lower() == 'log':
@@ -2421,7 +2421,7 @@ class _AxesBase(martist.Artist):
                 dl.extend(y_finite)
 
             bb = mtransforms.BboxBase.union(dl)
-            x0, x1 = getattr(bb, interval)
+            x0orig, x1orig = x0, x1 = getattr(bb, interval)
             locator = axis.get_major_locator()
             x0, x1 = locator.nonsingular(x0, x1)
 
@@ -2430,10 +2430,6 @@ class _AxesBase(martist.Artist):
             minpos = getattr(bb, minpos)
             transform = axis.get_transform()
             inverse_trans = transform.inverted()
-            # We cannot use exact equality due to floating point issues e.g.
-            # with streamplot.
-            do_lower_margin = not np.any(np.isclose(x0, stickies))
-            do_upper_margin = not np.any(np.isclose(x1, stickies))
             x0, x1 = axis._scale.limit_range_for_scale(x0, x1, minpos)
             x0t, x1t = transform.transform([x0, x1])
 
@@ -2443,12 +2439,23 @@ class _AxesBase(martist.Artist):
                 # If at least one bound isn't finite, set margin to zero
                 delta = 0
 
-            if do_lower_margin:
-                x0t -= delta
-            if do_upper_margin:
-                x1t += delta
+            x0t -= delta
+            x1t += delta
+
             x0, x1 = inverse_trans.transform([x0t, x1t])
 
+            # We cannot use exact equality due to floating point issues e.g.
+            # with streamplot.  The tolerances come from isclose().
+            stickies_minus_tol = stickies - 1e-5 * np.abs(stickies) - 1e-8
+            stickies_plus_tol = stickies + 1e-5 * np.abs(stickies) + 1e-8
+
+            i0orig, i0 = stickies_minus_tol.searchsorted([x0orig, x0])
+            if i0orig != i0:  # Crossed a sticky boundary.
+                x0 = stickies[i0orig - 1]  # Go back to sticky boundary.
+            i1orig, i1 = stickies_plus_tol.searchsorted([x1orig, x1])
+            if i1orig != i1:
+                x1 = stickies[i1orig]
+
             if not self._tight:
                 x0, x1 = locator.view_limits(x0, x1)
             set_bound(x0, x1)
```

Haven't tested if this breaks other stuff.  Also needs changelog.