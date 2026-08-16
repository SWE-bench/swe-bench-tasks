`read_crn` returns -99999 instead of `NaN`
**Describe the bug**
`read_crn` fails to map -99999 to `NaN`

**To Reproduce**
```python
from pvlib.iotools import read_crn
crn = read_crn('https://www.ncei.noaa.gov/pub/data/uscrn/products/subhourly01/2021/CRNS0101-05-2021-NY_Millbrook_3_W.txt')
crn.loc['2021-12-14 0930':'2021-12-14 1130', 'ghi']
2021-12-14 09:30:00+00:00        0.0
2021-12-14 09:35:00+00:00        0.0
2021-12-14 09:40:00+00:00        0.0
2021-12-14 09:45:00+00:00        0.0
2021-12-14 09:50:00+00:00        0.0
2021-12-14 09:55:00+00:00        0.0
2021-12-14 10:00:00+00:00        0.0
2021-12-14 10:05:00+00:00   -99999.0
2021-12-14 10:10:00+00:00   -99999.0
2021-12-14 10:15:00+00:00   -99999.0
2021-12-14 10:20:00+00:00   -99999.0
2021-12-14 10:25:00+00:00   -99999.0
2021-12-14 10:30:00+00:00   -99999.0
2021-12-14 10:35:00+00:00   -99999.0
2021-12-14 10:40:00+00:00   -99999.0
2021-12-14 10:45:00+00:00   -99999.0
2021-12-14 10:50:00+00:00   -99999.0
2021-12-14 10:55:00+00:00   -99999.0
2021-12-14 11:00:00+00:00   -99999.0
2021-12-14 11:05:00+00:00        0.0
2021-12-14 11:10:00+00:00        0.0
2021-12-14 11:15:00+00:00        0.0
2021-12-14 11:20:00+00:00        0.0
2021-12-14 11:25:00+00:00        0.0
2021-12-14 11:30:00+00:00        0.0
Name: ghi, dtype: float64
```

**Expected behavior**
Should return `NaN` instead of -99999

**Versions:**
 - ``pvlib.__version__``: 0.9.0
 - ``pandas.__version__``: 1.0.3 (doesn't matter)
 - python: 3.7

**Additional context**

Documentation [here](https://www.ncei.noaa.gov/pub/data/uscrn/products/subhourly01/) says

>          C.  Missing data are indicated by the lowest possible integer for a 
>             given column format, such as -9999.0 for 7-character fields with 
>             one decimal place or -99.000 for 7-character fields with three
>             decimal places.

So we should change 

https://github.com/pvlib/pvlib-python/blob/1ab0eb20f9cd9fb9f7a0ddf35f81283f2648e34a/pvlib/iotools/crn.py#L112-L117

to include -99999 and perhaps -999999. Or do the smarter thing as discussed in the comment.

also https://github.com/SolarArbiter/solarforecastarbiter-core/issues/773
