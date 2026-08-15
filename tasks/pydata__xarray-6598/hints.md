Thanks @sappjw -- this is a distillation of the bug derived from your example:

```
>>> import numpy as np
>>> import xarray as xr
>>> xr.coding.times.decode_cf_datetime(np.uint32(50), "seconds since 2018-08-22T03:23:03Z")
array('2018-08-22T03:23:05.755359744', dtype='datetime64[ns]')
```

I believe the solution is to also cast all unsigned integer values -- anything with `dtype.kind == "u"` -- to `np.int64` values here:
https://github.com/pydata/xarray/blob/770e878663b03bd83d2c28af0643770bdd43c3da/xarray/coding/times.py#L220-L224
Ordinarily we might worry about overflow in this context -- i.e. some `np.uint64` values cannot be represented by `np.int64` values -- but I believe since [we already verify that the minimum and maximum value of the input array can be represented by nanosecond-precision timedelta values](https://github.com/pydata/xarray/blob/770e878663b03bd83d2c28af0643770bdd43c3da/xarray/coding/times.py#L217-L218), we can safely do this.