The warning comes from NumPy, so not sure there is much Matplotlib can do? I'll close this, but feel free to reopen if you have another opinion (and sorry for letting this go unnoticed for so long).
@oscargus, could matplotlib just catch the warning at plot time?

I figure if the behavior is intentional from matplotlib, it would be nice if it didn't warn.
Ahh, I should have checked what happens in latest Matplotlib. Now it actually breaks:

```
---------------------------------------------------------------------------
StopIteration                             Traceback (most recent call last)
<ipython-input-2-18fe43def80a> in <cell line: 1>()
----> 1 plt.scatter(np.ones(10), np.ones(10), c=np.full(10, np.nan))

~\matplotlib\lib\matplotlib\pyplot.py in scatter(x, y, s, c, marker, cmap, norm, vmin, vmax, alpha, linewidths, edgecolors, plotnonfinite, data, **kwargs)
   2820         vmin=None, vmax=None, alpha=None, linewidths=None, *,
   2821         edgecolors=None, plotnonfinite=False, data=None, **kwargs):
-> 2822     __ret = gca().scatter(
   2823         x, y, s=s, c=c, marker=marker, cmap=cmap, norm=norm,
   2824         vmin=vmin, vmax=vmax, alpha=alpha, linewidths=linewidths,

~\matplotlib\lib\matplotlib\__init__.py in inner(ax, data, *args, **kwargs)
   1446     def inner(ax, *args, data=None, **kwargs):
   1447         if data is None:
-> 1448             return func(ax, *map(sanitize_sequence, args), **kwargs)
   1449
   1450         bound = new_sig.bind(ax, *args, **kwargs)

~\matplotlib\lib\matplotlib\axes\_axes.py in scatter(self, x, y, s, c, marker, cmap, norm, vmin, vmax, alpha, linewidths, edgecolors, plotnonfinite, **kwargs)
   4590             orig_edgecolor = kwargs.get('edgecolor', None)
   4591         c, colors, edgecolors = \
-> 4592             self._parse_scatter_color_args(
   4593                 c, edgecolors, kwargs, x.size,
   4594                 get_next_color_func=self._get_patches_for_fill.get_next_color)

~\matplotlib\lib\matplotlib\axes\_axes.py in _parse_scatter_color_args(c, edgecolors, kwargs, xsize, get_next_color_func)
   4388             isinstance(c, str)
   4389             or (np.iterable(c) and len(c) > 0
-> 4390                 and isinstance(cbook._safe_first_finite(c), str)))
   4391
   4392         def invalid_shape_exception(csize, xsize):

~\matplotlib\lib\matplotlib\cbook\__init__.py in _safe_first_finite(obj, skip_nonfinite)
   1713                            "support generators as input")
   1714     else:
-> 1715         return next(val for val in obj if safe_isfinite(val))
   1716
   1717

StopIteration:
```

Pinging @tacaswell who seems to have worked on `_safe_first_finite` most recently (although not sure when the issue arise).

Regarding if it is intentional or not can be discussed. We don't raise the warning and if we catch it, it may lead to confusion. At least in the general case.

Possible duplicate of #18294.