temperature.fuentes errors when given tz-aware inputs on pandas>=1.0.0
**Describe the bug**
When the weather timeseries inputs to `temperature.fuentes` have tz-aware index, an internal call to `np.diff(index)` returns an array of `Timedelta` objects instead of an array of nanosecond ints, throwing an error immediately after.  The error only happens when using pandas>=1.0.0; using 0.25.3 runs successfully, but emits the warning:

```
  /home/kevin/anaconda3/envs/pvlib-dev/lib/python3.7/site-packages/numpy/lib/function_base.py:1243: FutureWarning: Converting timezone-aware DatetimeArray to timezone-naive ndarray with 'datetime64[ns]' dtype. In the future, this will return an ndarray with 'object' dtype where each element is a 'pandas.Timestamp' with the correct 'tz'.
  	To accept the future behavior, pass 'dtype=object'.
  	To keep the old behavior, pass 'dtype="datetime64[ns]"'.
    a = asanyarray(a)
```

**To Reproduce**
```python
In [1]: import pvlib
   ...: import pandas as pd
   ...: 
   ...: index_naive = pd.date_range('2019-01-01', freq='h', periods=3)
   ...: 
   ...: kwargs = {
   ...:     'poa_global': pd.Series(1000, index_naive),
   ...:     'temp_air': pd.Series(20, index_naive),
   ...:     'wind_speed': pd.Series(1, index_naive),
   ...:     'noct_installed': 45
   ...: }
   ...: 

In [2]: print(pvlib.temperature.fuentes(**kwargs))
2019-01-01 00:00:00    47.85
2019-01-01 01:00:00    50.85
2019-01-01 02:00:00    50.85
Freq: H, Name: tmod, dtype: float64

In [3]: kwargs['poa_global'].index = index_naive.tz_localize('UTC')
   ...: print(pvlib.temperature.fuentes(**kwargs))
   ...: 
Traceback (most recent call last):

  File "<ipython-input-3-ff99badadc91>", line 2, in <module>
    print(pvlib.temperature.fuentes(**kwargs))

  File "/home/kevin/anaconda3/lib/python3.7/site-packages/pvlib/temperature.py", line 602, in fuentes
    timedelta_hours = np.diff(poa_global.index).astype(float) / 1e9 / 60 / 60

TypeError: float() argument must be a string or a number, not 'Timedelta'
```

**Expected behavior**
`temperature.fuentes` should work with both tz-naive and tz-aware inputs.


**Versions:**
 - ``pvlib.__version__``: 0.8.0
 - ``pandas.__version__``: 1.0.0+
 - python: 3.7.4 (default, Aug 13 2019, 20:35:49) \n[GCC 7.3.0]


