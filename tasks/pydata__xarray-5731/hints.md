Thanks @Gijom , I can repro.

I think the fix should be fairly easy, if someone wants to take a swing. I'm not sure why the existing tests don't cover it.
The responsible code for the error originally comes from the call to `da_a = da_a.map_blocks(_get_valid_values, args=[da_b])`, which aim is to remove nan values from both DataArrays. I am confused by this given that the code lines below seems to accumplish something similar (despite of the comment saying it should not):
```python
# 4. Compute covariance along the given dim
# N.B. `skipna=False` is required or there is a bug when computing
# auto-covariance. E.g. Try xr.cov(da,da) for
# da = xr.DataArray([[1, 2], [1, np.nan]], dims=["x", "time"])
cov = (demeaned_da_a * demeaned_da_b).sum(dim=dim, skipna=True, min_count=1) / (
    valid_count
)
```

In any case, the parrallel module imports dask in a try catch block to ignore the import error. So this is not a surprise that when using dask latter there is an error if it was not imported. I can see two possibilities:
- encapsulate all dask calls in a similar try/catch block
- set a boolean in the first place and do the tests only if dask is correctly imported

Now I do not have any big picure there so there are probably better solutions.
I had a look to it this morning and I think I managed to solve the issue by replacing the calls to `dask.is_dask_collection` by `is_duck_dask_array` from the `pycompat` module.

For (successful) testing I used the same code as above plus the following:
```python
ds_dask = ds.chunk({"t": 10})

yy = xr.corr(ds['y'], ds['y']).to_numpy()
yy_dask = xr.corr(ds_dask['y'], ds_dask['y']).to_numpy()
yx = xr.corr(ds['y'], ds['x']).to_numpy()
yx_dask = xr.corr(ds_dask['y'], ds_dask['x']).to_numpy()
np.testing.assert_allclose(yy, yy_dask), "YY: {} is different from {}".format(yy, yy_dask)
np.testing.assert_allclose(yx, yx_dask), "YX: {} is different from {}".format(yx, yx_dask)
```
The results are not exactly identical but almost which is probably due to numerical approximations of multiple computations in the dask case.

I also tested the correlation of simple DataArrays without dask installed and the result seem coherent (close to 0 for uncorrelated data and very close to 1 when correlating identical variables).

Should I make a pull request ? Should I implement this test ? Any others ?

That sounds great @Gijom ! Thanks for working through that. A PR would be welcome!

In the tests, we should be running this outside a `@requires_dask` decorated test, so that this gets tested without dask. If you can find that, great, otherwise someone can help.
Thanks @Gijom this is a dupe of https://github.com/pydata/xarray/issues/3391

Please send your changes in a pull request, we'd be happy to merge it after reviewing. Thank you!