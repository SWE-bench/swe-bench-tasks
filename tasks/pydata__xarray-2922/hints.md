Module error checking, etc., this would look something like:

``` python
def average(self, dim=None, weights=None):
    if weights is None:
        return self.mean(dim)
    else:
        return (self * weights).sum(dim) / weights.sum(dim)
```

This is pretty easy to do manually, but I can see the value in having the standard method around, so I'm definitely open to PRs to add this functionality.

This is has to be adjusted if there are `NaN` in the array. `weights.sum(dim)` needs to be corrected not to count weights on indices where there is a `NaN` in `self`. 

Is there a better way to get the correct weights than:

```
total_weights = weights.sum(dim) * self / self
```

It should probably not be used on a Dataset as every DataArray may have its own `NaN` structure. Or the equivalent Dataset method should loop through the DataArrays.

Possibly using where, e.g., `weights.where(self.notnull()).sum(dim)`.

Thanks - that seems to be the fastest possibility. I wrote the functions for Dataset and DataArray

``` python
def average_da(self, dim=None, weights=None):
    """
    weighted average for DataArrays

    Parameters
    ----------
    dim : str or sequence of str, optional
        Dimension(s) over which to apply average.
    weights : DataArray
        weights to apply. Shape must be broadcastable to shape of self.

    Returns
    -------
    reduced : DataArray
        New DataArray with average applied to its data and the indicated
        dimension(s) removed.

    """

    if weights is None:
        return self.mean(dim)
    else:
        if not isinstance(weights, xray.DataArray):
            raise ValueError("weights must be a DataArray")

        # if NaNs are present, we need individual weights
        if self.notnull().any():
            total_weights = weights.where(self.notnull()).sum(dim=dim)
        else:
            total_weights = weights.sum(dim)

        return (self * weights).sum(dim) / total_weights

# -----------------------------------------------------------------------------

def average_ds(self, dim=None, weights=None):
    """
    weighted average for Datasets

    Parameters
    ----------
    dim : str or sequence of str, optional
        Dimension(s) over which to apply average.
    weights : DataArray
        weights to apply. Shape must be broadcastable to shape of data.

    Returns
    -------
    reduced : Dataset
        New Dataset with average applied to its data and the indicated
        dimension(s) removed.

    """

    if weights is None:
        return self.mean(dim)
    else:
        return self.apply(average_da, dim=dim, weights=weights)
```

They can be combined to one function:

``` python
def average(data, dim=None, weights=None):
    """
    weighted average for xray objects

    Parameters
    ----------
    data : Dataset or DataArray
        the xray object to average over
    dim : str or sequence of str, optional
        Dimension(s) over which to apply average.
    weights : DataArray
        weights to apply. Shape must be broadcastable to shape of data.

    Returns
    -------
    reduced : Dataset or DataArray
        New xray object with average applied to its data and the indicated
        dimension(s) removed.

    """

    if isinstance(data, xray.Dataset):
        return average_ds(data, dim, weights)
    elif isinstance(data, xray.DataArray):
        return average_da(data, dim, weights)
    else:
        raise ValueError("date must be an xray Dataset or DataArray")
```

Or a monkey patch:

``` python
xray.DataArray.average = average_da
xray.Dataset.average = average_ds
```

@MaximilianR has suggested a `groupby`/`rolling`-like interface to weighted reductions. 

``` Python
da.weighted(weights=ds.dim).mean()
# or maybe
da.weighted(time=days_per_month(da.time)).mean()
```

I really like this idea, as does @shoyer.  I'm going to close my PR in hopes of this becoming reality.

I would suggest not using keyword arguments for `weighted`. Instead, just align based on the labels of the argument like regular xarray operations. So we'd write `da.weighted(days_per_month(da.time)).mean()`

Sounds like a clean solution. Then we can defer handling of NaN in the weights to `weighted` (e.g. by a `skipna_weights` argument in `weighted`). Also returning `sum_of_weights` can be a method of the class.

We may still end up implementing all required methods separately in `weighted`. For mean we do:

```
(data * weights / sum_of_weights).sum(dim=dim)
```

i.e. we use `sum` and not `mean`. We could rewrite this to:

```
(data * weights / sum_of_weights).mean(dim=dim) * weights.count(dim=dim)
```

However, I think this can not be generalized to a `reduce` function. See e.g. for `std` http://stackoverflow.com/questions/30383270/how-do-i-calculate-the-standard-deviation-between-weighted-measurements

Additionally, `weighted` does not make sense for many operations (I would say) e.g.: `min`, `max`, `count`, ...

Do we want

```
da.weighted(weight, dim='time').mean()
```

or

```
da.weighted(weight).mean(dim='time')
```

@mathause -

I would think you want the latter (`da.weighted(weight).mean(dim='time')`). `weighted` should handle the brodcasting of `weight` such that you could do this:

``` Python
>>> da.shape
(72, 10, 15)
>>> da.dims
('time', 'x', 'y')
>>> weights = some_func_of_time(time)
>>> da.weighted(weights).mean(dim=('time', 'x'))
...
```

Yes, +1 for `da.weighted(weight).mean(dim='time')`. The `mean` method on `weighted` should have the same arguments as the `mean` method on `DataArray` -- it's just changed due to the context.

> We may still end up implementing all required methods separately in weighted.

This is a fair point, I haven't looked in to the details of these implementations yet. But I expect there are still at least a few picks of logic that we will be able to share.

@mathause can you please comment on the status of this issue?  Is there an associated PR somewhere?  Thanks!
Hi,

my research group recently discussed weighted averaging with x-array, and I was wondering if there had been any progress with implementing this? I'd be happy to get involved if help is needed.

Thanks!
Hi,

This would be a really nice feature to have. I'd be happy to help too.

Thank you
Found this issue due to @rabernats [blogpost](https://medium.com/pangeo/supporting-new-xarray-contributors-6c42b12b0811). This is a much requested feature in our working group, and it would be great to build onto it in xgcm aswell.
I would be very keen to help this advance. 
It would be great to have some progress on this issue!  @mathause, @pgierz, @markelg, or @jbusecke if there is anything we can do to help you get started let us know.
I have to say that I am still pretty bad at thinking fully object orientented, but is this what we want in general?
A subclass `of xr.DataArray` which gets initialized with a weight array and with some logic for nans then 'knows' about the weight count? Where would I find a good analogue for this sort of organization? In the `rolling` class?

I like the syntax proposed by @jhamman above, but I am wondering what happens in a slightly modified example:
```
>>> da.shape
(72, 10, 15)
>>> da.dims
('time', 'x', 'y')
>>> weights = some_func_of_x(x)
>>> da.weighted(weights).mean(dim=('x', 'y'))
```
I think we should maybe build in a warning that when the `weights` array does not contain both of the average dimensions? 

It was mentioned that the functions on `...weighted()`, would have to be mostly rewritten since the logic for a weigthed average and std differs. What other functions should be included (if any)?
> I think we should maybe build in a warning that when the weights array does not contain both of the average dimensions?

hmm.. the intent here would be that the weights are broadcasted against the input array no? Not sure that a warning is required. e.g. @shoyer's comment above:

> I would suggest not using keyword arguments for `weighted`. Instead, just align based on the labels of the argument like regular xarray operations. So we'd write `da.weighted(days_per_month(da.time)).mean()`

Are we going to require that the argument to `weighted` is a `DataArray` that shares at least one dimension with `da`?
Point taken. I am still not thinking general enough :-)

> Are we going to require that the argument to weighted is a DataArray that shares at least one dimension with da?

This sounds good to me. 

With regard to the implementation, I thought of orienting myself along the lines of `groupby`, `rolling` or `resample`. Or are there any concerns for this specific method?
Maybe a bad question, but is there a good jumping off point to gain some familiarity with the code base? It’s admittedly my first time looking at xarray from the inside...
@pgierz take a look at the "good first issue" label: https://github.com/pydata/xarray/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22
@pgierz  - Our documentation has a page on [contributing](http://xarray.pydata.org/en/stable/contributing.html) which I encourage you to read through. ~Unfortunately, we don't have any "developer documentation" to explain the actual code base itself. That would be good to add at some point.~
**Edit**: that was wrong. We have a page on [xarray internals](http://xarray.pydata.org/en/stable/internals.html).
 
Once you have your local development environment set up and your fork cloned, the next step is to start exploring the source code and figuring out where changes need to be made. At that point, you can post any questions you have here and we will be happy to give you some guidance.
Can the stats functions from https://esmlab.readthedocs.io/en/latest/api.html#statistics-functions be used?
> With regard to the implementation, I thought of orienting myself along the lines of groupby, rolling or resample. Or are there any concerns for this specific method?

I would do the same i.e. take inspiration from the groupby / rolling / resample modules. 