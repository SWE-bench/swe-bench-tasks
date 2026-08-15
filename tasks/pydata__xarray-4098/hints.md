Why won't this be fixed?

I think some clarification in the documentation would be useful. Currently they say:

> xarray supports “group by” operations with the same API as pandas 
> [and that the required parameter for Dataset/DataArray.groupby is an]
> Array whose unique values should be used to group this array.

However, pandas supports grouping by a function or by _any_ array (e.g. it can be a pandas object or a numpy array). The xarray API is narrower than pandas, and has an undocumented requirement of a _**named** DataArray_ (contrasting xarray behaviour of creating default names like "dim_0" elsewhere). 

``` python
import numpy as np
data = np.arange(10) + 10 # test data
f = lambda x: np.floor_divide(x,2) # grouping key

import pandas as pd
for key in f, f(data), pd.Series(f(data)):
    print pd.Series(data).groupby(key).mean().values
    print pd.DataFrame({'thing':data}).groupby(key).mean().thing.values
# these pandas examples are all equivalent

import xarray as xr
da = xr.DataArray(data)
key = xr.DataArray(f(data))
key2 = xr.DataArray(f(data), name='key')
print da.groupby(key2).mean().values # this line works
print da.groupby(key).mean().values # broken: ValueError: `group` must have a name
```

This issue dates to very early in the days of xarray, before we even had a direct `DataArray` constructor. I have no idea exactly what I was thinking here.

I agree, it would be more consistent and user friendly to pick a default name for the group (maybe `'group'`). Any interest in putting together a PR?
