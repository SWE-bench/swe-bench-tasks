The same happens for `skipna=True`:
```python
xr.DataArray([1.]).sum(skipna=False, min_count=1)
```
I think `sum` is defined here:

https://github.com/pydata/xarray/blob/6c1203afbbeb25251705a3bf19c7a7bbe5c0bbf4/xarray/core/duck_array_ops.py#L346

but I am not sure how to best get rid of the unnecessary keyword argument.

