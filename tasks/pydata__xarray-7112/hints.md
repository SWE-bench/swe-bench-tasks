CC @headtr1ck any idea if this is supposed to work with your new #7089?
I get a similar error for different structures and if I do something like `data_arr.where(data_arr > 5, drop=True)`. In this case I have dask array based DataArrays and dask ends up trying to hash the object and it ends up in a loop trying to get xarray to hash the DataArray or something and xarray trying to hash the DataArrays inside `.attrs`.

```
In [9]: import dask.array as da

In [15]: a = xr.DataArray(da.zeros(5.0), attrs={}, dims=("a_dim",))

In [16]: b = xr.DataArray(da.zeros(8.0), attrs={}, dims=("b_dim",))

In [20]: a.attrs["other"] = b

In [24]: lons = xr.DataArray(da.random.random(8), attrs={"ancillary_variables": [b]})

In [25]: lats = xr.DataArray(da.random.random(8), attrs={"ancillary_variables": [b]})

In [26]: b.attrs["some_attr"] = [lons, lats]

In [27]: cond = a > 5

In [28]: c = a.where(cond, drop=True)
...
File ~/miniconda3/envs/satpy_py310/lib/python3.10/site-packages/dask/utils.py:1982, in _HashIdWrapper.__hash__(self)
   1981 def __hash__(self):
-> 1982     return id(self.wrapped)

RecursionError: maximum recursion depth exceeded while calling a Python object

```
I basically copied the behavior of `Dataset.copy` which should already show this problem.
In principle we are doing a `new_attrs = copy.deepcopy(attrs)`.

I would claim that the new behavior is correct, but maybe other devs can confirm this.

Coming from netCDF, it does not really make sense to put complex objects in attrs, but I guess for in-memory only it works.
I'd have to check, but this structure I *think* was originally produce by xarray reading a CF compliant NetCDF file. That is my memory at least. It could be that our library (satpy) is doing this as a convenience, replacing the name of an ancillary variable with the DataArray of that ancillary variable.

My other new issue seems to be related to `.copy()` doing a `.copy()` on dask arrays which then makes them not equivalent anymore. Working on an MVCE now.
Hmmm, python seems to deal with this reasonably for its builtins:

```python
In [1]: a = [1]

In [2]: b = [a]

In [3]: a.append(b)

In [4]: import copy

In [5]: copy.deepcopy(a)
Out[5]: [1, [[...]]]
```

I doubt this is getting hit _that_ much given it requires a recursive data structure, but it does seem like a gnarly error.

Is there some feature that python uses to check whether a data structure is recursive when it's copying, which we're not taking advantage of? I can look more later.
> Is there some feature that python uses to check whether a data structure is recursive when it's copying, which we're not taking advantage of? I can look more later.

yes, `def __deepcopy__(self, memo=None)` has the `memo` argument exactly for the purpose of dealing with recursion, see https://docs.python.org/3/library/copy.html. 
Currently, xarray's `__deepcopy__` methods do not pass on the memo argument when deepcopying its components.
I think our implementations of `copy(deep=True)` and `__deepcopy__` are reverted, the first should call the latter and not the other way around to be able to pass the memo dict.

This will lead to a bit of duplicate code between `__copy__` and `__deepcopy__` but would be the correct way.
To avoid code duplication you may consider moving all logic from the `copy` methods to new `_copy` methods and extending that with an optional `memo` argument and have the `copy`, `__copy__` and `__deepcopy__` methods as thin wrappers around it.
I will set up a PR for that.
Another issue has arisen: the repr is also broken for recursive data. With your example python should also raise a RecursionError when looking at this data?
Ok, even `xarray.testing.assert_identical` fails with recursive definitions.
Are we sure that it is a good idea to support this?