As listed in breaking changes, the new polyval algorithm uses the values of the `coord` argument and not the index coordinate.

Your coordinate is a Timedelta `values -values[0]`, try using that directly or `azimuth_time.coords["azimuth_time"]`.
Thanks - I think I might be misunderstanding how the new implementation works.
I tried the following changes, but both of them return an error:
```python
xr.polyval(values - values[0], polyfit_coefficients)
```
```
Traceback (most recent call last):
  File "/Users/mattia/MyGit/test.py", line 31, in <module>
    xr.polyval(values - values[0], polyfit_coefficients)
  File "/Users/mattia/MyGit/xarray/xarray/core/computation.py", line 1908, in polyval
    coord = _ensure_numeric(coord)  # type: ignore # https://github.com/python/mypy/issues/1533 ?
  File "/Users/mattia/MyGit/xarray/xarray/core/computation.py", line 1949, in _ensure_numeric
    return to_floatable(data)
  File "/Users/mattia/MyGit/xarray/xarray/core/computation.py", line 1939, in to_floatable
    x.data,
ValueError: cannot include dtype 'm' in a buffer
```

```python
xr.polyval(azimuth_time.coords["azimuth_time"], polyfit_coefficients)
```
```
Traceback (most recent call last):
  File "/Users/mattia/MyGit/test.py", line 31, in <module>
    xr.polyval(azimuth_time.coords["azimuth_time"], polyfit_coefficients)
  File "/Users/mattia/MyGit/xarray/xarray/core/computation.py", line 1908, in polyval
    coord = _ensure_numeric(coord)  # type: ignore # https://github.com/python/mypy/issues/1533 ?
  File "/Users/mattia/MyGit/xarray/xarray/core/computation.py", line 1949, in _ensure_numeric
    return to_floatable(data)
  File "/Users/mattia/MyGit/xarray/xarray/core/computation.py", line 1938, in to_floatable
    data=datetime_to_numeric(
  File "/Users/mattia/MyGit/xarray/xarray/core/duck_array_ops.py", line 434, in datetime_to_numeric
    array = array - offset
numpy.core._exceptions._UFuncBinaryResolutionError: ufunc 'subtract' cannot use operands with types dtype('<m8[ns]') and dtype('<M8[D]')
```
Ok, the first idea does not work since values is a numpy array.

The second idea should work, so this is a bug.
It seems that polyval does not work with timedeltas, I will look into that.