Thanks for the report.

We did not consider to store an object type array other than string, but it should be supported.

I think we should improve this line,
https://github.com/pydata/xarray/blob/39b2a37207fc8e6c5199ba9386831ba7eb06d82b/xarray/core/variable.py#L171-L172

We internally use many inhouse array-like classes and this line is used to avoid multiple nesting.
I think we can change this line to more explicit type checking.

Currently, the following does not work either
```python
In [11]: xr.DataArray(HasValues, dims=[])
Out[11]: 
<xarray.DataArray ()>
array(5)
```

For your perticular purpose, the following will be working
```
bad_indexed.loc[{'dim_0': 0}] = np.array(HasValues(), dtype=object)
```
> We internally use many inhouse array-like classes and this line is used to avoid multiple nesting.
I think we can change this line to more explicit type checking.

Agreed, we should do more explicit type checking. It's a little silly to assume that every object with a `.values` attribute is an xarray.DataArray, xarray.Variable, pandas.Series or pandas.DataFrame.
I was wondering if this is still up for consideration?

> Thank you for your help! If I can be brought to better understand any constraints to adjacent issues, I can consider drafting a fix for this.

Same here.
Yes, we would still welcome a fix here.

We could probably change that line to something like:
```
if isinstance(data, (pd.Series, pd.Index, pd.DataFrame)):
    data = data.values
```