this also came up in #4141, where we proposed to work around this by using `DataArray.where` (as far as I can tell this doesn't work for you, though).

There are two issues here: first of all, by default `DataArray.__eq__` removes the attributes, so without calling `xr.set_options(keep_attrs=True)` `data == 1` won't keep the attributes (see also #3891).

However, even if we pass a `xarray` object with attributes, `xr.where` does not pass `keep_attrs` to `apply_ufunc`. Once it does the attributes will be propagated, but simply adding `keep_attrs=True` seems like a breaking change. Do we need to add a `keep_attrs` kwarg or get the value from `OPTIONS["keep_attrs"]`?
you can work around this by using the `where` method instead of the global `xr.where` function:
```python
In [8]: da.where(da == 0, -1).attrs
Out[8]: {'foo': 'bar'}
```

For more information on the current state of attribute propagation, see #3891.
Thanks a lot @keewis !