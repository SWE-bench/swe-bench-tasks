Thanks @kefirbandi, can you send in a PR?
Jumping from 2022.3.0 to 2022.6.0 this issue has re-emerged for me.
> Jumping from 2022.3.0 to 2022.6.0 this issue has re-emerged for me.

I am seeing the same issue as well.
Cannot reproduce on current master using
```python
import xarray as xr

ds = xr.Dataset({"a": (["x"], [1, 2, 3])}, attrs={"t": 1})
ds2 = ds.copy(deep=True)
ds.attrs["t"] = 5
print(ds2.attrs)  # returns: {'t': 1}
```
even with
```python
In [1]: import xarray as xr
   ...: 
   ...: ds = xr.Dataset({"a": ("x", [1, 2, 3], {"t": 0})}, attrs={"t": 1})
   ...: ds2 = ds.copy(deep=True)
   ...: ds.attrs["t"] = 5
   ...: ds.a.attrs["t"] = 6
   ...: 
   ...: display(ds2, ds2.a)
<xarray.Dataset>
Dimensions:  (x: 3)
Dimensions without coordinates: x
Data variables:
    a        (x) int64 1 2 3
Attributes:
    t:        1
<xarray.DataArray 'a' (x: 3)>
array([1, 2, 3])
Dimensions without coordinates: x
Attributes:
    t:        0
```
I cannot reproduce. @Ch-Meier, @DerPlankton13, can either of you post a minimal example demonstrating the issue? 