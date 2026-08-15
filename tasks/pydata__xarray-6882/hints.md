Thanks for the report -- marking this as a bug.

If you are able to put together a PR to fix this that would be appreciated.
I might try it out but most likely not before the end of the week.
I'd still like to fix this but I have too much workload at the moment.  However, I've noticed it's also triggered if the time axis is not empty, but we subselect data such that it becomes empty, then run `ds.load()`.
I ran into this issue with a [file from the GOES-17 lightning mapper](https://noaa-goes17.s3.amazonaws.com/GLM-L2-LCFA/2019/111/06/OR_GLM-L2-LCFA_G17_s20191110644200_e20191110644370_c20191110645086.nc). 

A simple script to reproduce is:
```
d=xr.open_dataset('OR_GLM-L2-LCFA_G17_s20191110644200_e20191110644370_c20191110645086.nc')
d.load()
```

giving the error

```
----> 1 d.load()

~/anaconda/envs/isatss/lib/python3.7/site-packages/xarray/core/dataset.py in load(self, **kwargs)
    516         for k, v in self.variables.items():
    517             if k not in lazy_data:
--> 518                 v.load()
    519 
    520         return self

~/anaconda/envs/isatss/lib/python3.7/site-packages/xarray/core/variable.py in load(self, **kwargs)
    325             self._data = as_compatible_data(self._data.compute(**kwargs))
    326         elif not isinstance(self._data, np.ndarray):
--> 327             self._data = np.asarray(self._data)
    328         return self
    329 

~/anaconda/envs/isatss/lib/python3.7/site-packages/numpy/core/numeric.py in asarray(a, dtype, order)
    499 
    500     """
--> 501     return array(a, dtype, copy=False, order=order)
    502 
    503 

~/anaconda/envs/isatss/lib/python3.7/site-packages/xarray/core/indexing.py in __array__(self, dtype)
    624 
    625     def __array__(self, dtype=None):
--> 626         self._ensure_cached()
    627         return np.asarray(self.array, dtype=dtype)
    628 

~/anaconda/envs/isatss/lib/python3.7/site-packages/xarray/core/indexing.py in _ensure_cached(self)
    621     def _ensure_cached(self):
    622         if not isinstance(self.array, NumpyIndexingAdapter):
--> 623             self.array = NumpyIndexingAdapter(np.asarray(self.array))
    624 
    625     def __array__(self, dtype=None):

~/anaconda/envs/isatss/lib/python3.7/site-packages/numpy/core/numeric.py in asarray(a, dtype, order)
    499 
    500     """
--> 501     return array(a, dtype, copy=False, order=order)
    502 
    503 

~/anaconda/envs/isatss/lib/python3.7/site-packages/xarray/core/indexing.py in __array__(self, dtype)
    602 
    603     def __array__(self, dtype=None):
--> 604         return np.asarray(self.array, dtype=dtype)
    605 
    606     def __getitem__(self, key):

~/anaconda/envs/isatss/lib/python3.7/site-packages/numpy/core/numeric.py in asarray(a, dtype, order)
    499 
    500     """
--> 501     return array(a, dtype, copy=False, order=order)
    502 
    503 

~/anaconda/envs/isatss/lib/python3.7/site-packages/xarray/core/indexing.py in __array__(self, dtype)
    508     def __array__(self, dtype=None):
    509         array = as_indexable(self.array)
--> 510         return np.asarray(array[self.key], dtype=None)
    511 
    512     def transpose(self, order):

~/anaconda/envs/isatss/lib/python3.7/site-packages/numpy/core/numeric.py in asarray(a, dtype, order)
    499 
    500     """
--> 501     return array(a, dtype, copy=False, order=order)
    502 
    503 

~/anaconda/envs/isatss/lib/python3.7/site-packages/xarray/coding/variables.py in __array__(self, dtype)
     66 
     67     def __array__(self, dtype=None):
---> 68         return self.func(self.array)
     69 
     70     def __repr__(self):

~/anaconda/envs/isatss/lib/python3.7/site-packages/xarray/coding/times.py in decode_cf_datetime(num_dates, units, calendar, use_cftime)
    174         try:
    175             dates = _decode_datetime_with_pandas(flat_num_dates, units,
--> 176                                                  calendar)
    177         except (OutOfBoundsDatetime, OverflowError):
    178             dates = _decode_datetime_with_cftime(

~/anaconda/envs/isatss/lib/python3.7/site-packages/xarray/coding/times.py in _decode_datetime_with_pandas(flat_num_dates, units, calendar)
    139         warnings.filterwarnings('ignore', 'invalid value encountered',
    140                                 RuntimeWarning)
--> 141         pd.to_timedelta(flat_num_dates.min(), delta) + ref_date
    142         pd.to_timedelta(flat_num_dates.max(), delta) + ref_date
    143 

~/anaconda/envs/isatss/lib/python3.7/site-packages/numpy/core/_methods.py in _amin(a, axis, out, keepdims, initial)
     30 def _amin(a, axis=None, out=None, keepdims=False,
     31           initial=_NoValue):
---> 32     return umr_minimum(a, axis, None, out, keepdims, initial)
     33 
     34 def _sum(a, axis=None, dtype=None, out=None, keepdims=False,

ValueError: zero-size array to reduction operation minimum which has no identity
```



Versions: `xarray = 0.12.1, pandas = 0.24.1`
I don't know if this issue is still relevant for xarray
But I encountered the same error with https://github.com/euroargodev/argopy 
and may be surprisingly, only with xarray version 0.16.1
Hello,

Using the same code sample:

```
import numpy
import xarray

ds = xarray.Dataset(
    {"a": ("x", [])},
    coords={"x": numpy.zeros(shape=0, dtype="M8[ns]")})

ds.to_netcdf("/tmp/test.nc")

xarray.open_dataset("/tmp/test.nc")
```

It works on xarray 0.17 but does not work anymore with xarray 0.18 & 0.18.2.

This [addition](https://github.com/pydata/xarray/blob/master/xarray/coding/times.py#L190-L193) seems to be responsible (coming from [this commit](https://github.com/pydata/xarray/commit/fbd48d4307502f7dbe8afa37b84df59e74407820)).
Has anyone found a workaround for this issue?  I am able to recreate the ValueError via @Thomas-Z's example using xarray 2022.6.0.