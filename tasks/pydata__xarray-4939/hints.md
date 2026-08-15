👍  that would be super useful!
coarsen is pretty similar to rolling AFAIR so it may not be too hard to implement a `.reduce` method.
As a workaround, it's possible to use rolling and .sel to keep only adjacent windows:

```python
ds
<xarray.Dataset>
Dimensions:  (x: 237, y: 69, z: 2)
Coordinates:
  * x        (x) int64 0 1 2 3 4 5 6 7 8 ... 228 229 230 231 232 233 234 235 236
  * y        (y) int64 0 1 2 3 4 5 6 7 8 9 10 ... 59 60 61 62 63 64 65 66 67 68
  * z        (z) int64 0 1
Data variables:
    data2D   (x, y) float64 dask.array<chunksize=(102, 42), meta=np.ndarray>
    data3D   (x, y, z) float64 dask.array<chunksize=(102, 42, 2), meta=np.ndarray>

# window size
window = {'x' : 51, 'y' : 21}
# window dims, prefixed by 'k_'
window_dims = {k: "k_%s" % k for k in window.keys()}
# dataset, with new dims as window. .sel drop sliding windows, to keep only adjacent ones.
ds_win = ds.rolling(window,center=True).construct(window_dims).sel(
            {k: slice(window[k]//2,None,window[k]) for k in window.keys()})

<xarray.Dataset>
Dimensions:  (k_x: 51, k_y: 21, x: 5, y: 3, z: 2)
Coordinates:
  * x        (x) int64 25 76 127 178 229
  * y        (y) int64 10 31 52
  * z        (z) int64 0 1
Dimensions without coordinates: k_x, k_y
Data variables:
    data2D   (x, y, k_x, k_y) float64 dask.array<chunksize=(2, 2, 51, 21), meta=np.ndarray>
    data3D   (x, y, z, k_x, k_y) float64 dask.array<chunksize=(2, 2, 2, 51, 21), meta=np.ndarray>

# now, use reduce on a standard dataset, using window k_dims as dimensions
ds_red = ds_win.reduce(np.mean,dim=window_dims.values())

<xarray.Dataset>
Dimensions:  (x: 5, y: 3, z: 2)
Coordinates:
  * x        (x) int64 25 76 127 178 229
  * y        (y) int64 10 31 52
  * z        (z) int64 0 1
Data variables:
    data2D   (x, y) float64 dask.array<chunksize=(2, 2), meta=np.ndarray>
    data3D   (x, y, z) float64 dask.array<chunksize=(2, 2, 2), meta=np.ndarray>
```

Note that i was unable to use `unique`, because the size of the result depend on the data.

