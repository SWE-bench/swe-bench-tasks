The problem here is that the inline backend (which is provided by IPython) is applying the `bbox="tight"` argument to `savefig` (well, `print_figure`, but same idea)

The axes created by `axes_grid1.insetlocator.inset_axes` are not compatible with `tight_layout`.

Now, when you just call `fig.tight_layout()`, you get a warning but it doesn't raise, so there may be a way of at least detecting and warning rather than erroring, but not sure there is a good way of just not applying the tight layout with this backend...

Workarounds include:

- Use a backend other than inline (e.g. [ipympl](https://matplotlib.org/ipympl/) which is designed to give an interactive experience in Jupyter (`%matplotlib widget` to enable if installed)
- Use [`Axes.inset_axes`](https://matplotlib.org/stable/api/_as_gen/matplotlib.axes.Axes.inset_axes.html#matplotlib.axes.Axes.inset_axes) instead of the `mpl_toolkits` method. This does not have the automatic locating of the `axes_grid1` version, but may be sufficient for your use, just a little more manual to place the axes.
```
The axes created by axes_grid1.insetlocator.inset_axes are not compatible with tight_layout.

```

Agreed - but it seems that `get_window_extent` should work.  For some reason we aren't plumbing the figure into the inset_axes.  Recently, we stopped passing the renderer by default to `get_window_extent` because artists are supposed to know their figure. However, apparently not for this artist.  This probably bisects to https://github.com/matplotlib/matplotlib/pull/22745
Unfortunately it is still more complicated than simply setting `figure` on the offending object (which is the `mpl_toolkits.axes_grid1.inset_locator.AnchoredSizeLocator`, which inherits 
(transitively) from `OffsetBox`)

While that gets a bit further, the `get_offset` method is still called, and that needs a renderer with a `points_to_pixels` method...

I can update `__call__` to add the logic to get the renderer from the figure if it is passed in as None, and then it seems to work, but still a little skeptical about whether a better arrangement of plumbing these bits together exists.

```diff
diff --git a/lib/mpl_toolkits/axes_grid1/inset_locator.py b/lib/mpl_toolkits/axes_grid1/inset_locator.py
index 9d35051074..1fdf99d573 100644
--- a/lib/mpl_toolkits/axes_grid1/inset_locator.py
+++ b/lib/mpl_toolkits/axes_grid1/inset_locator.py
@@ -69,6 +69,8 @@ class AnchoredLocatorBase(AnchoredOffsetbox):
         raise RuntimeError("No draw method should be called")
 
     def __call__(self, ax, renderer):
+        if renderer is None:
+            renderer = self.figure._get_renderer()
         self.axes = ax
         bbox = self.get_window_extent(renderer)
         px, py = self.get_offset(bbox.width, bbox.height, 0, 0, renderer)
@@ -287,6 +289,7 @@ def _add_inset_axes(parent_axes, axes_class, axes_kwargs, axes_locator):
     inset_axes = axes_class(
         parent_axes.figure, parent_axes.get_position(),
         **{"navigate": False, **axes_kwargs, "axes_locator": axes_locator})
+    axes_locator.figure = inset_axes.figure
     return parent_axes.figure.add_axes(inset_axes)
```

Setting the figure manually feels a little iffy, but so does calling `add_artist`, honestly, for something that is not really drawn or used...

And the renderer logic is also a little iffy as the figure is often still not set, so perhaps resolving that earlier in the call stack is a better idea?

But regardless, it _works_, at least for `axes_grid1.inset_locator.inset_axes` as the entry point (I suspect if you tried to use the lower level things, it would still be easy to get tripped up, so if there was a path that would resolve that, that would be ideal, just not sure what that actually looks like)
The above looks close, but I don't think you need to plumb the figure in?  Just do `renderer = ax.figure._get_renderer()` since axes have to have figures?  
Ah, yes, that does make sense... it was a path function where I added that first but still had another failure, but I now see that I'm pretty sure the fix for the second will also fix the first, rendering the first fix moot. (and then yes, the iffiness of setting figure of an artist that is not actually in the axes goes away if you just get the `ax.figure`'s renderer.)