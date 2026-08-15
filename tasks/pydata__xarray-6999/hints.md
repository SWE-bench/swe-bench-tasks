This has been discussed in #4825.

A third option for `rename{_vars}` would be to rename the coordinate and its index (if any), regardless of whether the old and new names correspond to existing dimensions. We plan to drop the concept of a "dimension coordinate" with an implicit index in favor of indexes explicitly part of Xarray's data model (see https://github.com/pydata/xarray/projects/1), so that it will be possible to set indexes for non-dimension coordinates and/or set dimension coordinates without indexes.

Re your example, in #5692 `data.rename({"c": "x"})` does not implicitly create anymore an indexed coordinate (no `*`):

```python
data_renamed
# <xarray.DataArray (x: 3)>
# array([5, 6, 7])
# Coordinates:
#     x        (x) int64 1 2 3
```

Instead, it should be possible to directly set an index for the `c` coordinate without the need to rename it, e.g.,

```python
# API has still to be defined
data_indexed = data.set_index("c", index_cls=xr.PandasIndex)

data_indexed.sel(c=[1, 2])
# <xarray.DataArray (x: 2)>
# array([5, 6])
# Coordinates:
#   * c       (x) int64 1 2
```


> `data.rename({"c": "x"})` does not implicitly create anymore an indexed coordinate

I have code that relied on automatic index creation through rename and some downstream code broke.

I think we need to address this through a warning or error so that users can be alerted that behaviour has changed.