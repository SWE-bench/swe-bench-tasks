I guess we need `np.asarray(scale_factor).item()`
But what did we do before?
I think it just did `np.array([1, 2, 3.]) * [5]` numpy coverts the `[5]` to an array with one element, which is why it worked:

```python
xr.coding.variables._scale_offset_decoding(np.array([1, 2, 3.]), [5], None, np.float)

```

https://github.com/pydata/xarray/blob/49d03d246ce657e0cd3be0582334a1a023c4b374/xarray/coding/variables.py#L217
Ok then I am 👍  on @dcherian's solution.