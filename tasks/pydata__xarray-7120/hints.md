I can't reproduce on our dev branch. Can you try upgrading xarray please?

EDIT: can't reproduce on 2022.03.0 either.
Thanks. I upgraded to 2022.03.0 

I am still getting the error

```
Python 3.9.12 (main, Apr  5 2022, 06:56:58) 
[GCC 7.5.0] :: Anaconda, Inc. on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import xarray as xr
>>> xr.__version__
'2022.3.0'
>>> ds = xr.Dataset({"foo": (("x", "y", "z"), [[[42]]]), "bar": (("y", "z"), [[24]])})
>>> ds.transpose(['y','z','y'])
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/nbhome/f1p/miniconda3/envs/f1p_gfdl/lib/python3.9/site-packages/xarray/core/dataset.py", line 4650, in transpose
    _ = list(infix_dims(dims, self.dims, missing_dims))
  File "/nbhome/f1p/miniconda3/envs/f1p_gfdl/lib/python3.9/site-packages/xarray/core/utils.py", line 786, in infix_dims
    existing_dims = drop_missing_dims(dims_supplied, dims_all, missing_dims)
  File "/nbhome/f1p/miniconda3/envs/f1p_gfdl/lib/python3.9/site-packages/xarray/core/utils.py", line 874, in drop_missing_dims
    supplied_dims_set = {val for val in supplied_dims if val is not ...}
  File "/nbhome/f1p/miniconda3/envs/f1p_gfdl/lib/python3.9/site-packages/xarray/core/utils.py", line 874, in <setcomp>
    supplied_dims_set = {val for val in supplied_dims if val is not ...}
TypeError: unhashable type: 'list'
```
```
ds.transpose(['y','z','y'])
```

Ah... Reemove the list here and try `ds.transpose("y", "z", x")` (no list) which is what you have in the first post. 
Oh... I am so sorry about this. This works as expected now. 
It's weird that using list seemed to have worked at some point. Thanks a lot for your help
I think we should raise a nicer error message. Transpose is an outlier in  our API. In nearly every other function, you are expected to pass a list of dimension names.