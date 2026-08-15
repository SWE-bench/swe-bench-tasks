I like this better than the current  create/remove/replace scheme, but just to be clear- using this method means folks would have to go in manually and create a subplot for each spec, right? So this feature is just providing the ability to layout and identify axes in the same way as subplot_mosaic? 
We could do this, but it seems relatively convoluted, and likely to end up in a dusty corner...  Isn't the fundamental problem that we can't change projections post-facto?  Can we not do that somehow?  `ax.change_projection()` would be best, but `axnew = fig.change_projection(ax, proj)` would perhaps be bearable.  

> and likely to end up in a dusty corner

I think that the loops for adding a new subplot would probably look almost identical to the ones for changing the projection, so I'm not sure that the discoverablity/documentation problem favors one over the other, especially if either solution is added to the mosaic tutorial and as a nice gallery example. 
The projection machinery can pick a different class to use for the returned `Axes` instance.  While you can change classes in Python (which we do in mplot3d), I am not a huge fan of doing more of that to I think changing the projection is off the table.

----

Unfortunately we already pass `subplot_kw` to all of them and do not want to try to de-conflict the namespaces.  Making something like:

```python
from matplotlib import pyplot as plt

fig, axd = plt.subplot_mosaic(
    "AB;CC",
    needs_a_better_name={"A": {"projection": "polar"}, "B": {"projection": "3d"}},
)

```

work is not that bad (I used a bad name to avoid getting lost in discussions of the parameter name just yet ;) ).

![so](https://user-images.githubusercontent.com/199813/204940851-cb3b7304-d18f-4a7b-9657-88eaee19ec58.png)


```diff
diff --git a/lib/matplotlib/figure.py b/lib/matplotlib/figure.py
index 6c18ba1a64..e75b973044 100644
--- a/lib/matplotlib/figure.py
+++ b/lib/matplotlib/figure.py
@@ -1771,7 +1771,8 @@ default: %(va)s

     def subplot_mosaic(self, mosaic, *, sharex=False, sharey=False,
                        width_ratios=None, height_ratios=None,
-                       empty_sentinel='.', subplot_kw=None, gridspec_kw=None):
+                       empty_sentinel='.', subplot_kw=None, gridspec_kw=None,
+                       needs_a_better_name=None):
         """
         Build a layout of Axes based on ASCII art or nested lists.

@@ -1868,6 +1869,7 @@ default: %(va)s
         """
         subplot_kw = subplot_kw or {}
         gridspec_kw = dict(gridspec_kw or {})
+        needs_a_better_name = needs_a_better_name or {}
         if height_ratios is not None:
             if 'height_ratios' in gridspec_kw:
                 raise ValueError("'height_ratios' must not be defined both as "
@@ -2011,7 +2013,11 @@ default: %(va)s
                         raise ValueError(f"There are duplicate keys {name} "
                                          f"in the layout\n{mosaic!r}")
                     ax = self.add_subplot(
-                        gs[slc], **{'label': str(name), **subplot_kw}
+                        gs[slc], **{
+                            'label': str(name),
+                            **subplot_kw,
+                            **needs_a_better_name.get(name, {})
+                        }
                     )
                     output[name] = ax
                 elif method == 'nested':
diff --git a/lib/matplotlib/pyplot.py b/lib/matplotlib/pyplot.py
index 79c33a6bac..f384fe747b 100644
--- a/lib/matplotlib/pyplot.py
+++ b/lib/matplotlib/pyplot.py
@@ -1474,7 +1474,8 @@ def subplots(nrows=1, ncols=1, *, sharex=False, sharey=False, squeeze=True,

 def subplot_mosaic(mosaic, *, sharex=False, sharey=False,
                    width_ratios=None, height_ratios=None, empty_sentinel='.',
-                   subplot_kw=None, gridspec_kw=None, **fig_kw):
+                   subplot_kw=None, gridspec_kw=None,
+                   needs_a_better_name=None, **fig_kw):
     """
     Build a layout of Axes based on ASCII art or nested lists.

@@ -1571,7 +1572,8 @@ def subplot_mosaic(mosaic, *, sharex=False, sharey=False,
         mosaic, sharex=sharex, sharey=sharey,
         height_ratios=height_ratios, width_ratios=width_ratios,
         subplot_kw=subplot_kw, gridspec_kw=gridspec_kw,
-        empty_sentinel=empty_sentinel
+        empty_sentinel=empty_sentinel,
+        needs_a_better_name=needs_a_better_name,
     )
     return fig, ax_dict
```
Just to chime in and say that I have also had the desire to have a dropdown selector of geographic projections to click through/change at will. (A nice example here: https://observablehq.com/@d3/projection-transitions) If someone calls `ax.change_projection()` I think we could get away with some documentation that the class type may change underneath them..., and do some fiddling on our end to update the transforms and `__class__` attributes properly (which is probably not trivial to get right).
Ah, I see that #20392 proposed to pass subplot_kws as an array of dicts (which is a bit of a mess once you have axes spanning multiple cells), and I can't find if a concrete proposal had been made in the original thread (#16603); but I agree that passing instead a dict of dicts (label -> subplot_kw) as proposed by @tacaswell seems not too bad.
My first follow-up feature request would be to do

```python
from matplotlib import pyplot as plt

fig, axd = plt.subplot_mosaic(
    "AB;CC",
    needs_a_better_name={"AB": {"projection": "polar"}},
)
```
to make both the top panels polar.  Sometimes you might want like 10 axes with 5 in one projection and 5 in another.
> ```
> needs_a_better_name={"AB": {"projection": "polar"}},
> ```

I think the generic solution is
```
needs_a_better_name={
    ("name1", "name2"): {"projection": "polar"}},
    "name3": {"projection": "3d"},
}
```
i.e. keys are strings or tuples of strings.

Maybe with the extension: If the mosaic spec is a string (i.e. we only have single-char names), any key with len>1 is interpreted as `tuple(key)`, i.e. "AB" is internally converted to ("A", "B").
> we already pass subplot_kw to all of them and do not want to try to de-conflict the namespaces

So which one would get priority if like `subplot_kw` and `needs_a_better_name` get passed the same key?
In Tom's diff, `needs_a_better_name` would get priority as it is later in the unpacking.

```python
>>> {"a": 1, "a":2}
{'a': 2}
```

This makes intuitive sense as it allows you to set some generic settings for most subplots but override with the more specific kwargs for individual subplot, which you simply would not do if that had no effect.
> This makes intuitive sense 

Yeah, it's just gonna have to be documented in neon lights and commented as this is a for free of python dict implementation. I'm worried though about two keywords that do almost the same thing but one is vectorized, since that feels like `color` vs `colors`
Implementing @rcomer 's idea for the short hand was easy, but I have more concerns about the general case as we will technically work with _any_ hashables as the keys so there is an ambiguity there.  Not insurmountable, but annoying.

Pulling out a (maybe private) `gridspec_mosaic` may still be useful so we can implement `subfigure_mosaic` as well....