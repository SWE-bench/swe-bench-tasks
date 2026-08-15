Thanks for the report, the culprit is likely

https://github.com/pydata/xarray/blob/5296ed18272a856d478fbbb3d3253205508d1c2d/xarray/core/nanops.py#L34

We fixed a similar problem in [weighted](https://github.com/pydata/xarray/blob/master/xarray/core/weighted.py#L100).
grepping the code, the only other function that calls `_maybe_null_out` is prod, and I can confirm the problem also exists there. Updated the title, MCVE for prod:

```python
import numpy as np
import xarray as xr


def worker(da):
    if da.shape == (0, 0):
        return da

    raise RuntimeError("I was evaluated")


da = xr.DataArray(
    np.random.normal(size=(20, 500)),
    dims=("x", "y"),
    coords=(np.arange(20), np.arange(500)),
)

da = da.chunk(dict(x=5))
lazy = da.map_blocks(worker)
result1 = lazy.prod("x", skipna=True)
result2 = lazy.prod("x", skipna=True, min_count=5)
```
Can we use `np.where` instead of this if condition?
A quick check with the debugger and it is the `null_mask.any()` call that is causing it to compute.

I think I've found another problem with `_maybe_null_out` if it is reducing over all dimensions. With the altered MCVE

```python
import numpy as np
import xarray as xr

def worker(da):
    if da.shape == (0, 0):
        return da

    res = xr.full_like(da, np.nan)
    res[0, 0] = 1
    return res


da = xr.DataArray(
    np.random.normal(size=(20, 500)),
    dims=("x", "y"),
    coords=(np.arange(20), np.arange(500)),
)

da = da.chunk(dict(x=5))
lazy = da.map_blocks(worker)
result_allaxes = lazy.sum(skipna=True, min_count=5)
result_allaxes.load()
```

I would expect `result_allaxes` to be nan since there are four blocks and therefore four non-nan values, less than min_count. Instead it is 4.

The problem seems to be the dtype check:

https://github.com/pydata/xarray/blob/5296ed18272a856d478fbbb3d3253205508d1c2d/xarray/core/nanops.py#L39

The test returns True for float64 and so the block isn't run. Another MCVE:

```python
import numpy as np
from xarray.core import dtypes

print(dtypes.NAT_TYPES)
print(np.dtype("float64") in dtypes.NAT_TYPES)
```

Output:
```console
(numpy.datetime64('NaT'), numpy.timedelta64('NaT'))
True
```
where I think False would be expected. Should I open a separate issue for this or can we track it here too?
@dcherian it looks like that works. A better test script:

```python
import numpy as np
import xarray as xr
from xarray.tests import raise_if_dask_computes


def worker(da):
    if da.shape == (0, 0):
        return da

    return da.where(da > 1)


np.random.seed(1023)
da = xr.DataArray(
    np.random.normal(size=(20, 500)),
    dims=("x", "y"),
    coords=(np.arange(20), np.arange(500)),
)

da = da.chunk(dict(x=5))
lazy = da.map_blocks(worker)

with raise_if_dask_computes():
    result = lazy.sum("x", skipna=True, min_count=5)

result.load()

assert np.isnan(result[0])
assert not np.isnan(result[6])
```

If I then remove the `if null_mask.any()` check and the following block, and replace it with

```python
dtype, fill_value = dtypes.maybe_promote(result.dtype)
result = result.astype(dtype)
result = np.where(null_mask, fill_value, result)
```
it passes. I can start working on a pull request with these tests and changes if that looks acceptable to you.

~~How would you suggest handling the possible type promotion from the current `dtype, fill_value = dtypes.maybe_promote(result.dtype)` line? Currently it only tries promoting if the mask is True anywhere. Always promote, or just use the fill value and hope it works out?~~