Agreed, this is definitely a bug. I'm not sure if we can define meaningful behavior for this case, but at the least we should raise a better error.
@shoyer I would like to work on this issue (hopefully my first contribution). 

I believe the error should indicate that we cannot groupby an empty group. This would be consistent with the documentation:

```
DataArray.groupby(group, squeeze: bool = True, restore_coord_dims: Optional[bool] = None)
Parameters
groupstr, DataArray or IndexVariable
Array whose unique values should be used to group this array. If a string, must be the name of a variable contained in this dataset.
````

For the groupby class, we can raise an error in case the groupby object instantiation does not specify values to be grouped by. In the case above:

```
ValueError: variable to groupby must not be empty

```

If you find such a solution acceptable, I would create a pull request.

Thank you in advance