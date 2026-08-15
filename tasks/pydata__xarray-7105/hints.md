@benbovy I tracked this down to

``` python
>>> mda.one.to_index()
# v2022.06.0
MultiIndex([('a', 0),
            ('a', 1),
            ('b', 0),
            ('b', 1),
            ('c', 0),
            ('c', 1)],
           names=['one', 'two'])

# v2022.03.0
Index(['a', 'a', 'b', 'b', 'c', 'c'], dtype='object', name='x')
```

We call `to_index` here in `safe_cast_to_index`:
https://github.com/pydata/xarray/blob/f8fee902360f2330ab8c002d54480d357365c172/xarray/core/utils.py#L115-L140

Not sure if the fix should be only in the GroupBy specifically or more generally in `safe_cast_to_index`

The GroupBy context is
https://github.com/pydata/xarray/blob/f8fee902360f2330ab8c002d54480d357365c172/xarray/core/groupby.py#L434
After trying to dig down further into the code, I saw that grouping over levels seems to be broken generally (up-to-date main branch at time of writing), i.e.

```python 
import pandas as pd
import numpy as np
import xarray as xr

midx = pd.MultiIndex.from_product([list("abc"), [0, 1]], names=("one", "two"))
mda = xr.DataArray(np.random.rand(6, 3), [("x", midx), ("y", range(3))])
mda.groupby("one").sum()
```

raises:
```python

  File ".../xarray/xarray/core/_reductions.py", line 5055, in sum
    return self.reduce(

  File ".../xarray/xarray/core/groupby.py", line 1191, in reduce
    return self.map(reduce_array, shortcut=shortcut)

  File ".../xarray/xarray/core/groupby.py", line 1095, in map
    return self._combine(applied, shortcut=shortcut)

  File ".../xarray/xarray/core/groupby.py", line 1127, in _combine
    index, index_vars = create_default_index_implicit(coord)

  File ".../xarray/xarray/core/indexes.py", line 974, in create_default_index_implicit
    index = PandasMultiIndex(array, name)

  File ".../xarray/xarray/core/indexes.py", line 552, in __init__
    raise ValueError(

ValueError: conflicting multi-index level name 'one' with dimension 'one'
```
in the function ``create_default_index_implicit``. I am still a bit puzzled how to approach this. Any idea @benbovy?
Thanks @emmaai for the issue report and thanks @dcherian and @FabianHofmann for tracking it down.

There is a lot of complexity related to `pandas.MultiIndex` special cases and it's been difficult to avoid new issues arising during the index refactor.

`create_default_index_implicit` has some hacks to create xarray objects directly from `pandas.MultiIndex` instances (e.g., `xr.Dataset(coords={"x": pd_midx})`) or even from xarray objects wrapping multi-indexes. The error raised here suggests that the issue should fixed before this call... Probably in `safe_cast_to_index` indeed.

We should probably avoid using `.to_index()` internally, or should we even deprecate it?  The fact that `mda.one.to_index()` (in v2022.3.0) doesn't return the same result than `mda.indexes["one"]` adds more confusion than it adds value. Actually, in the long-term I'd be for deprecating all `pandas.MultiIndex` special cases in Xarray.


