@rabernat - Depending on the structure of the dataset, another possibility that would speed up some `open_mfdataset` tasks substantially is to implement the step of opening each file and getting its metadata in in some parallel way (dask/joblib/etc.) and either returning the just dataset schema or a picklable version of the dataset itself.  I think this will only be able to work with `autoclose=True` but it could be quite useful when working with many files. 
I did not really find an elegant solution. What I did was just specify all dims and coords as `drop_variables` and then update those from a master file with 
```
ds.update(ds_master)
``` 
Perhaps this could be generalized in a sense, by reading all coords and dims just from the first file. 
Would these two options be necessarily mutually exclusive?

I think parallelizing the read in sounds amazing.  

But isnt there some merit in skipping some of the checks all together, if the user is sure about the structure of the data contained in the many files?

I am often working with the aforementioned type of data (many files either contain a new timestep or a different variable, but most of the dimensions/coordinates are the same). 

In some cases I am finding that reading the data "lazily" consumes a significant amount of the time in my workflow. I am unsure how hard this would be to achieve, and perhaps it is not worth it after all.

Just putting out a few ideas, while I wait for my `xr.open_mfdataset` to finish :-)
@jbusecke - No. These options are not mutually exclusive. The parallel open is, in my opinion, the lowest hanging fruit so that's why I started there. There are other improvements that we can tackle incrementally. 
Awesome, thanks for the clarification.
I just looked at #1981 and it seems indeed very elegant (in fact I just now used this approach to parallelize printing of movie frames!) Thanks for that!

I am currently motivated to fix this.

1. Over in https://github.com/pydata/xarray/pull/1413#issuecomment-302843502 @rabernat mentioned
> allowing the user to pass join='exact' via open_mfdataset. A related optimization would be to allow the user to pass coords='minimal' (or other concat coords options) via open_mfdataset.

2. @shoyer suggested calling decode_cf later here though perhaps this wont help too much: https://github.com/pydata/xarray/issues/1385#issuecomment-439263419

Is this all that we can do on the xarray side?
@dcherian I'm sorry, I'm very interested in this but after reading the issues I'm still not clear on what's being proposed:

What exactly is the bottleneck? Is it reading the coords from all the files? Is it loading the coord values into memory? Is it performing the alignment checks on those coords once they're in memory? Is it performing alignment checks on the dimensions? Is this suggestion relevant to datasets that don't have any coords?

Which of these steps would a `join='exact'` option omit?

> A related optimization would be to allow the user to pass coords='minimal' (or other concat coords options) via open_mfdataset.

But this is already an option to `open_mfdataset`?
The original issue of this thread is that you sometimes might want to *disable* alignment checks for coordinates other than the `concat_dim` and only check for same dimensions and dimension shapes. 

When you `xr.merge` with `join='exact'`, it still checks for alignment (see https://github.com/pydata/xarray/pull/1330#issuecomment-302711852), but does not join the coordinates if they are not aligned. This behavior (not joining) is also included in what @rabernat envisioned here, but his suggestion goes beyond that: you don't even load coordinate values from all but the first dataset and just blindly trust that they are aligned.

So `xr.open_mfdataset(join='exact', coords='minimal')` does not fix this issue here, I think.
So I think it is quite important to consider this issue together with #2697. An xml specification called [NCML](https://www.unidata.ucar.edu/software/thredds/current/netcdf-java/ncml/) already exists which tells software how to put together multiple netCDF files into a single virtual netcdf. We should leverage this existing spec as much as possible.

A realistic use case for me is that I have, say 1000 files of high-res model output, each with large coordinate variables, all generated from the same model run. If we want to  for for which we *know a priori* that certain coordinates (dimension coordinates or otherwise) are identical, we could save a lot of disk reads (the slow part of `open_mfdataset`) by never reading those coordinates at all. Enabling this would require a pretty low-level change in xarray. For example, we couldn't even rely on `open_dataset` in its current form to open files, because `open_dataset` eagerly loads all dimension coordinates into indexes. One way forward might be to create a new Store class.

For a catalog of tricks I use to optimize opening these sorts of big, complex, multi-file datasets (e.g. CMIP), check out
https://github.com/pangeo-data/esgf2xarray/blob/master/esgf2zarr/aggregate.py

One common use-case is files with large numbers of `concat_dim`-invariant non-dimensional co-ordinates.  This is easy to speed up by dropping those variables from all but the first file. 

e.g.
https://github.com/pangeo-data/esgf2xarray/blob/6a5e4df0d329c2f23b403cbfbb65f0f1dfa98d52/esgf2zarr/aggregate.py#L107-L110
``` python
    # keep only coordinates from first ensemble member to simplify merge
    first = member_dsets_aligned[0]
    rest = [mds.reset_coords(drop=True) for mds in member_dsets_aligned[1:]]
    objs_to_concat = [first] + rest
```

Similarly https://github.com/NCAR/intake-esm/blob/e86a8e8a80ce0fd4198665dbef3ba46af264b5ea/intake_esm/aggregate.py#L53-L57

``` python
def merge_vars_two_datasets(ds1, ds2):
    """
    Merge two datasets, dropping all variables from
    second dataset that already exist in the first dataset's coordinates.
    """
```

See also #2039 (second code block)

One way to do this might be to add a `master_file` kwarg to `open_mfdataset`. This would imply `coords='minimal', join='exact'` (I think; `prealigned=True` in some other proposals) and would drop non-dimensional coordinates from all but the first file and then call concat. 

As bonus it would assign attributes from the `master_file` to the merged dataset (for which I think there are open issues) : this functionality exists in `netCDF4.MFDataset` so that's a plus.

EDIT: #2039 (third code block) is also a possibility. This might look like
``` python
xr.open_mfdataset('files*.nc', master_file='first', concat_dim='time')
```
in which case the first file is read; all coords that are not `concat_dim` become `drop_variables` for an `open_dataset` call that reads the remaining files. We then merge with the first dataset and assign attrs.

EDIT2: `master_file` combines two different functionalities here: specifying a "template file" and a file to choose attributes from. So maybe we need two kwargs: `template_file` and `attrs_from`?