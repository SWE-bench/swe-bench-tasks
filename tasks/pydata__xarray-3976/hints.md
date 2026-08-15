Yes, this is unfortunate. The reasoning: https://github.com/pydata/xarray/blob/732b6cd6248ce715da74f3cd7a0e211eaa1d0aa2/xarray/core/dataarray.py#L2618-L2621

It may be possible to at align in some cases (e.g. if the indexes are bijective / one-to-one, or the values are already floats). Or a better error message; even one containing that comment would be better.
@mancellin Are you up for sending in a PR with a better error message?
I can submit a PR. But the comment cited above is not totally clear to me.

The purpose of the conversion to floats is to have NaNs in case the shapes do not match. So the core of the issue is that A + B might not have the same shape as A, and thus in general A + B cannot replace A in-place.
Is that right?

Thanks in advance @mancellin 

Your comment is almost exactly right. It's that they might not align fully, rather than the shape; i.e. if your example had `range(1,5)` rather than `range(0,4)`, then the array would need to be converted to  float to add a `NaN`. Does that make sense?
Yes. But the not-in-place addition `A+B` works fine without conversion to float because it uses basically `xr.align(A, B, join='inner')`. If the in-place addition did the same, there would be no risk of type conversion. But I guess the in-place version would rather use something like `xr.align(A, B, join='left')` to guarantee that the shape and index of `A` does not change. Am I right?
Yes exactly! And I think in-place might be surprising if it changed the indexes of the left item; i.e. if you got this result from `A += B`:

```python

In [17]:
    ...:
    ...: import numpy as np
    ...: import xarray as xr
    ...:
    ...: n = 5
    ...:
    ...: d1 = np.arange(1, n+1)
    ...: np.random.shuffle(d1)
    ...: A = xr.DataArray(np.ones(n), coords=[('dim', d1)])
    ...:
    ...: d2 = np.arange(n)
    ...: np.random.shuffle(d2)
    ...: B = xr.DataArray(np.ones(n), coords=[('dim', d2)])
    ...:
    ...: A + B
Out[17]:
<xarray.DataArray (dim: 4)>
array([2., 2., 2., 2.])
Coordinates:
  * dim      (dim) int64 3 2 1 4
```

