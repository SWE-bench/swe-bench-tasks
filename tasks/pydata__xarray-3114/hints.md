As you've noticed, these arrays are "read only" because otherwise indexing can modify more than the original values, e.g., consider:
```python
original = xr.DataArray(np.zeros(3), dims='x')
result = original.expand_dims(y=2)
result.data.flags.writeable = True
result[0, 0] = 1
print(result)
```
Both "y" values were set to 1!
```
<xarray.DataArray (y: 2, x: 3)>
array([[1., 0., 0.],
       [1., 0., 0.]])
Dimensions without coordinates: y, x
```

The work around is to call `.copy()` on the array after calling `expand_dims()`, e.g.,
```
original = xr.DataArray(np.zeros(3), dims='x')
result = original.expand_dims(y=2).copy()
result[0, 0] = 1
print(result)
```
Now the correct result is printed:
```
<xarray.DataArray (y: 2, x: 3)>
array([[1., 0., 0.],
       [0., 0., 0.]])
Dimensions without coordinates: y, x
```

----------------

This is indeed intended behavior: by making the result read-only, we can expand dimensions without copying the original data, and without needing to worry about indexing modifying the wrong values.

That said, we could certainly improve the usability of this feature in xarray. Some options:
- Mention the work-around of using `.copy()` in the error message xarray prints when an array is read-only.
- Add a `copy` argument to `expand_dims`, so users can write `copy=True` if they want a writeable result.
- Consider changing the behavior when a dimension is inserted with size 1 to make the result writeable -- in this case, individual elements of result can be modified (which will also modify the input array). But maybe it would be surprising to users if the result of `expand_dims()` is sometimes but not always writeable? 
Thank you @shoyer for taking the time to educate me on this.  I understand completely now.

I agree that solutions one and two would be helpful for future developers new to Xarray and the expand_dims operation when they eventually encounter this behaviour.  I also agree that option three would be confusing, and had it of been implemented as such I would still have found myself to be asking a similar question about why it is like that.

Another option to consider which might be easier still would be to just update the expand_dims documentation to include a note about this behaviour and the copy solution.

Thanks again!
OK, we would definitely welcome a pull request to improve this error message and the documentation for `expand_dims`!

I lean slightly against adding the `copy` argument since it's just as easy to add `.copy()` afterwards (that's one less function argument).
Yes good point.  I do also think that the expand_dims interface should really only be responsible for that one single operation.  If you then want to make a copy then go ahead and use that separate method afterwards.

Ok great, if I get time later today I'll see if I can't pick that up; that is if someone hasn't already done so in the meantime.
I am also affected in some code which used to work with earlier versions of xarray. In this case, I call `ds.expand_dims('new_dim')` on some dataset (not DataArray), e.g.:
```
ds = xr.Dataset({'testvar': (['x'], np.zeros(3))})
ds1 = ds.expand_dims('y').copy()
ds1.testvar.data.flags

  C_CONTIGUOUS : True
  F_CONTIGUOUS : True
  OWNDATA : False
  WRITEABLE : False
  ALIGNED : True
  WRITEBACKIFCOPY : False
  UPDATEIFCOPY : False
```
The `.copy()` workaround is not helping in this case, I am not sure how to fix this?
I have just realized that `.copy(deep=True)` is a possible fix for datasets.