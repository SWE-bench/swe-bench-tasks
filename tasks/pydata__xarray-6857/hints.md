~can you try if setting `keep_attrs=True` helps?~

That's wrong, I can reproduce the side-effects. Not sure where that's coming from, though. And interestingly, only the first operand is mutated, `da_withoutunits == da_withunits` does not drop the units on `da_withunits`.
keep_attrs=True doesn't help
```python
In [1]: import xarray as xr
In [2]: xr.set_options(keep_attrs=True)
Out[2]: <xarray.core.options.set_options at 0x1789a959fa0>
In [3]: da_withunits = xr.DataArray([1, 1, 1], coords={"frequency": [1, 2, 3]})
In [4]: da_withunits.frequency.attrs["units"] = "GHz"
In [5]: da_withunits.frequency.units
Out[5]: 'GHz'
In [6]: da_withoutunits = xr.DataArray([1, 1, 1], coords={"frequency": [1, 2, 3]})
In [7]: da_withunits == da_withoutunits
Out[7]:
<xarray.DataArray (frequency: 3)>
array([ True,  True,  True])
Coordinates:
  * frequency  (frequency) int32 1 2 3

In [8]: da_withunits.frequency.units
---------------------------------------------------------------------------
AttributeError                            Traceback (most recent call last)
Input In [8], in <cell line: 1>()
----> 1 da_withunits.frequency.units
File ~\AppData\Local\Programs\Python\Python39\lib\site-packages\xarray\core\common.py:256, in AttrAccessMixin.__getattr__(self, name)
    254         with suppress(KeyError):
    255             return source[name]
--> 256 raise AttributeError(
    257     f"{type(self).__name__!r} object has no attribute {name!r}"
    258 )
AttributeError: 'DataArray' object has no attribute 'units'
```
bisecting tells me this is a regression introduced by #6389. Looking at the code, this happens because copying the variables with `variables.copy()` makes a shallow copy of the dictionary (and not its values), which means that we're actually mutating the `Dataset` variables. If I change that line to
```python
# make a shallow copy of each variable
new_variables = {name: var.copy() for name, var in variables.items()}
```
we stop mutating the dataset.

cc @benbovy