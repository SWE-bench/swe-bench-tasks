Xref: [Gitter Chat](https://gitter.im/pydata/xarray?at=5c88ef25d3b35423cbb02afc)
This has also implications for the output using `.to_netcdf()`. If we read a netcdf dataset (same structure as above) with `xr.open_dataset` and then do the above `xr.concat` and save the resulting dataset with `.to_netcdf` then the dimensions of the dataset will be reversed in the resulting file.

Now, as the `xr.concat` operation need to change the length of the dimension ('c', which is not allowed by netCDF library), this is done by creating a new dataset. In this creation process xarray obviously uses the alphanumerically sorted representation of the source dataset dimension's and not the creation order as in the source dataset. 

I did not find any hints in the docs on that topic.  I need to preserve the original dimension ordering as declared in the source dataset. How can I achieve this using xarray?
Your system might print dataset dimensions like `Frozen(SortedKeysDict({'c': 2, 'b': 3}))`, but the iteration order will always be sorted (including if you write the dataset to disk as netcdf file).

When we drop support for Python 3.5, xarray might switch to dimensions matching order of insertion, since we'll get that for free with Python dictionary. But I still doubt we would make any guarantees about preserving dimension order in xarray operations, just like we don't guarantee variable order as part of xarray's API. It should be deterministic (with fixed versions of xarray and dependencies), but you shouldn't write your code in a way that breaks if changes.

What's your actual use-case here? What are you trying to do that needs preserving of dimension order?
Thanks for looking into this @shoyer.

> Your system might print dataset dimensions like `Frozen(SortedKeysDict({'c': 2, 'b': 3}))`, but the iteration order will always be sorted (including if you write the dataset to disk as netcdf file).

This isn't true for my system. If we consider this example:

```python
data = np.zeros((2,3))
ds = xr.Dataset({'test': (['c', 'b'],  data)}, 
                coords={'c': (['c'], np.arange(data.shape[0])),
                        'b': (['b'], np.arange(data.shape[1])),})
ds.to_netcdf('test_dims.nc')
ds2 = xr.concat([ds, ds], dim='c')
ds2.to_netcdf('test_dims2.nc')
```
Dumping the created files gives the following:

```
netcdf test_dims {
dimensions:
        c = 2 ;
        b = 3 ;
variables:
        double test(c, b) ;
                test:_FillValue = NaN ;
        int64 c(c) ;
        int64 b(b) ;
data:

 test =
  0, 0, 0,
  0, 0, 0 ;

 c = 0, 1 ;

 b = 0, 1, 2 ;
}
```
```
netcdf test_dims2 {
dimensions:
        b = 3 ;
        c = 4 ;
variables:
        int64 b(b) ;
        double test(c, b) ;
                test:_FillValue = NaN ;
        int64 c(c) ;
data:

 b = 0, 1, 2 ;

 test =
  0, 0, 0,
  0, 0, 0,
  0, 0, 0,
  0, 0, 0 ;

 c = 0, 1, 0, 1 ;
}
```
My use case is, well, I have to use some legacy code.

Concerning my code, yes I'm trying to write it as robust as possible. Finally I wan't to replace the legacy code with the implementation relying completely on xarray, but that's a long way to go.



Dimensions are written to netCDF files in the order in which they appear on variables in the Dataset:
https://github.com/pydata/xarray/blob/f382fd840dafa5fdd95e66a7ddd15a3d498c1bce/xarray/backends/common.py#L325-L329

It sounds like your use-case is writing netCDF files to disk with a desired dimension order? We could conceivably add an "encoding" option to datasets for specifying dimension order, like how we support controlling unlimited dimensions.
> Dimensions are written to netCDF files in the order in which they appear on variables in the Dataset:

I was assuming something along that lines. But in my variable `test` the 'c' dim is first. And it is written correctly, if there are no coordinates in that dataset (test_dim0). If there are coordinates (test_dims2) the dimensions are written in wrong order. So there is something working in one config and not in the other.

My use case is, that the dimensions should appear in the same order as in the source files.
> I was assuming something along that lines. But in my variable `test` the 'c' dim is first. And it is written correctly, if there are no coordinates in that dataset (test_dim0). If there are coordinates (test_dims2) the dimensions are written in wrong order. So there is something working in one config and not in the other.

The order of dimensions in the netCDF file matches the order of their appearance on variables in the netCDF files. In your first file, it's `(c, b)` on variable `test`. In the second file, it's `b` on variable `b` and `c` from variable `test`.

> My use case is, that the dimensions should appear in the same order as in the source files.

Sorry, xarray is not going to satisfy this use. If you want this guarantee in all cases, you should pick a different tool.
@shoyer I'm sorry if I did not explain well enough and if my intentions were vague. So let me first clarify, I really appreciate all your hard work to make xarray better. I've adapted many of my workflows to use xarray and I'm happy that such a library exist.

Let's consider just one more example where I hopefully get better to the point of my problems in understanding.

Two files are created, same dimensions, same data, but one without coordinates the other with coordinates.

```python
data = np.zeros((2,3))
src_dim0 = xr.Dataset({'test': (['c', 'b'],  data)})
src_dim0.to_netcdf('src_dim0.nc')

src_dim1 = xr.Dataset({'test': (['c', 'b'],  data)}, 
                      coords={'c': (['c'], np.arange(data.shape[0])),
                              'b': (['b'], np.arange(data.shape[1])),})
src_dim1.to_netcdf('src_dim1.nc')
```
The dump of both:
```
netcdf src_dim0 {
dimensions:
	c = 2 ;
	b = 3 ;
variables:
	double test(c, b) ;
		test:_FillValue = NaN ;
data:

 test =
  0, 0, 0,
  0, 0, 0 ;
}

netcdf src_dim1 {
dimensions:
	c = 2 ;
	b = 3 ;
variables:
	double test(c, b) ;
		test:_FillValue = NaN ;
	int64 c(c) ;
	int64 b(b) ;
data:

 test =
  0, 0, 0,
  0, 0, 0 ;

 c = 0, 1 ;

 b = 0, 1, 2 ;
}
```

Now, from the dump, the 'c' dimension is first in both. Lets read those files again and concat them along the `c`-dimension:

```python
dst_dim0 = xr.open_dataset('src_dim0.nc')
dst_dim0 = xr.concat([dst_dim0, dst_dim0], dim='c')
dst_dim0.to_netcdf('dst_dim0.nc')

dst_dim1 = xr.open_dataset('src_dim1.nc')
dst_dim1 = xr.concat([dst_dim1, dst_dim1], dim='c')
dst_dim1.to_netcdf('dst_dim1.nc')
```

Now, and this is what confuses me, the file without coordinates has 'c' dimension first and the file with coordinates has 'b' dimension first.:
```
netcdf dst_dim0 {
dimensions:
	c = 4 ;
	b = 3 ;
variables:
	double test(c, b) ;
		test:_FillValue = NaN ;
data:

 test =
  0, 0, 0,
  0, 0, 0,
  0, 0, 0,
  0, 0, 0 ;
}

netcdf dst_dim1 {
dimensions:
	b = 3 ;
	c = 4 ;
variables:
	int64 b(b) ;
	double test(c, b) ;
		test:_FillValue = NaN ;
	int64 c(c) ;
data:

 b = 0, 1, 2 ;

 test =
  0, 0, 0,
  0, 0, 0,
  0, 0, 0,
  0, 0, 0 ;

 c = 0, 1, 0, 1 ;
}
```

I really like to understand why there is this difference. Thanks for your patience!
This is due to the internal implementation of `xarray.concat`, which sometimes reorders variables. I doubt the reordering was intentional. It's probably just a side effect of how `concat` takes multiple passes over different types of variables to figure out how to combine them.

You are welcome to take a look at improving this, though I doubt this would be particularly easy to fix. Certainly the code in `concat` could use some clean-up, and if we can preserve the order of variables on outputs that would be an improvement in usability. But it's still not something I would consider a "bug" *per se*.
@shoyer Yes, that was what I was assuming. But was a bit confused too, as the concat docs say, that dimension order is not affected. But maybe I get this wrong and the order of dimensions is not affected only for DataArrays.

IIUC xarray creates a new dataset during concat, because the dimensions cannot be expanded (due to netCDF4 limitations). So I would need to look at that specific part, where this creation process takes place. 

I would also not speak of "bug" here, but if such reordering happens only in certain conditions users (I mean at least me) can get confused.

I'll try to find out under what conditions this happens and try to come up with some workaround. Will also try ti find my way through the concat-mechanism. Again, I really appreciate your help in this issue. 
I can rename the issue to a somewhat better name, do you have a suggestion? **Ambiguous dimension reorder in Dataset concat** maybe?


Sorry, fat fingers...
@shoyer I'm working on a notebook with all testing inside. Just found that if I have 3 dimensions ('c', 'd', 'b') the ordering is preserved in ~any case~ (~with and~ without coords) for concat along any dimension. Will link the notebook next day.

Update: Need to be more thorough...with coordinates it reorders also with 3 dims.
Just as note for me, to not have to reiterate:

- It seems, that variables are handled in creation order. Means that `concat ` reads them, handles them (even if the variable remains unchanged) and writes them to the new dataset in that order.
- This does not happen for coordinate for some reason. There only the changed dimension is handled and written after the variables. The unaffected coordinates are written at the beginning before the variables.

Example (dst concat over 'x'):
The ordering of the src_dim1 is because the dimensions in the variables/coordinates are x,y,z in that order. The ordering of the dst_dim1 is because the dimensions in the variables/coordinates are z, y, x.
```
netcdf src_dim1 {
dimensions:
	x = 2 ;
	y = 3 ;
	z = 4 ;
variables:
	double test2(x, y) ;
		test2:_FillValue = NaN ;
	double test3(x, z) ;
		test3:_FillValue = NaN ;
	double test1(y, z) ;
		test1:_FillValue = NaN ;
	int64 z(z) ;
	int64 y(y) ;
	int64 x(x) ;
```
```
netcdf dst_dim1 {
dimensions:
	z = 4 ;
	y = 3 ;
	x = 4 ;
variables:
	int64 z(z) ;
	int64 y(y) ;
	double test2(x, y) ;
		test2:_FillValue = NaN ;
	double test3(x, z) ;
		test3:_FillValue = NaN ;
	double test1(x, y, z) ;
		test1:_FillValue = NaN ;
	int64 x(x) ;
```

It seems, that the two coordinates (z and y) are written first, then the variables, and then the changed coordinate. Now trying to find, where this happens. If the two coordinates would be written in the same way as the variables (and after them), then the ordering would be x,y,z as in the source. 


@shoyer I think I found the relevant lines of code in `combine.py`. It might be possible to preserve the (*correct*) order of dimensions at least with regard to their occurrence in variables (and not in coordinates). But that would mean to treat variables and coordinates consecutively in some way..

In the docs there is a Warning: 
*We are changing the behavior of iterating over a Dataset the next major release of xarray, to only include data variables instead of both data variables and coordinates. In the meantime, prefer iterating over ds.data_vars or ds.coords.* [below here](http://xarray.pydata.org/en/stable/data-structures.html#dataset-contents).

Does that mean that this also affects internal machinery (like in concat)? If so, could you point me to some code where this is taken care of or give some explanation or links where this is discussed?

Update: I' working with latest 0.12.0 release.

That warning should be removed — we already finished that deprecation cycle!
see https://github.com/pydata/xarray/pull/2818 for removing that warning
@shoyer Attached the description of the issue source and kind of workaround.

During `concat` a `result_vars = OrderedDict()` is created.
After that it is iterated over the first dataset `datasets[0].variables.items()` and those variables which are not affected by the `concat` are added to the `result_vars` :
https://github.com/pydata/xarray/blob/a5ca64ac5988f0c9c9c6b741a5de16e81b90cad5/xarray/core/combine.py#L244-L246

After several checks the affected variables are treated and added to `result_vars`:
https://github.com/pydata/xarray/blob/a5ca64ac5988f0c9c9c6b741a5de16e81b90cad5/xarray/core/combine.py#L301-L306

The comment indicates what you already mentioned, that the reorder might be unintentional. But due to the handling in two separate iterations over `datasets[0].variables`, the source variable order is not preserved (and with that in some cases the order of the dimensions).

This can be worked around by changing the second iteration to:
```python
# re-initialize result_vars to write in correct order
result_vars = OrderedDict()

# stack up each variable to fill-out the dataset (in order)
for k in datasets[0].variables:
    if k in concat_over:
        vars = ensure_common_dims([ds.variables[k] for ds in datasets])
        combined = concat_vars(vars, dim, positions)
        insert_result_variable(k, combined)
    else:
        insert_result_variable(k, datasets[0].variables[k])  
```
With this workaround applied, the `concat` works as expected and the variable/coordinate order (and with that the dimension order) is preserved. I'm thinking about a better solution but wanted to get some feedback from you first, if I#m on the right track. Thanks!
After checking a bit more in older issues, this seems related: https://github.com/pydata/xarray/pull/1049, ping @fmaussion.

And also @shoyer's [comment](https://github.com/pydata/xarray/pull/1049/files#r83541671) suggest that those two iterations/loops I mentioned above need to be addressed correctly.


don't use the `Coordinates` section to check the order. `Dataset` objects may have multiple data variables (each with a possibly different order of dimensions) so for displaying it needs to define some kind of order.

What you want to compare is the order of dimensions referenced by a variable:
```
<xarray.Dataset>
Dimensions:  (time: 1, x: 10, y: 10)
Coordinates:
  * time     (time) int64 0
  * y        (y) int64 0 1 2 3 4 5 6 7 8 9
  * x        (x) int64 0 1 2 3 4 5 6 7 8 9
Data variables:
    data     (time, y, x) bool False False False False ... False False False
             ^^^^^^^^^^^^
```
and you will notice that the order does not change.

To make this less confusing, maybe we should always sort the coordinates when displaying them? I'm guessing that right now they are displayed in the order they were added to the coordinates.
This rings a bell! It has be discussed in https://github.com/pydata/xarray/issues/2811. I've done extensive checks back then, but didn't come up with an PR.

My workaround or solution is outlined [in this comment](https://github.com/pydata/xarray/issues/2811#issuecomment-473810333). Code might have been changed!
@keewis yes you are right, but still a consistent ordering would be less confusing, including maybe also the Dimensions field.
Now Dimensions shows first x and then y, even though the data itself has y,x ordering.