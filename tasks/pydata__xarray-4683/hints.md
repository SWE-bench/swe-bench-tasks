Must have been  #4314
Oops. @rhkleijn This would be a relatively easy fix if you have the time to send in a PR
IIUC before PR #4314 `numpy.ndarray.astype` was used and the `order` parameter was just part of that. Looking through PR #4314 it seems that the 'casting' parameter required some special casing in duck_array_ops.py since not all duck arrays did support it (in particular sparse arrays only gained it very recently). In the current case the `order` parameter is not supported at all for sparse arrays. 

I am thinking it might not even be worthwhile to add support for an `order` parameter similar to the `numpy.ndarray.astype` method:

- It would add more special casing logic to xarray.
- To the user it would result in either noisy warnings or silently dropping parameters.
- To me, the kind of contiguousness seems more like an implementation detail of the array type of the underlying data than as a property of the encapsulating xarray object.
- For my use case (with numpy arrays as the underlying data) I can quite easily work around this issue by using something like `da.copy(data=np.asfortranarray(da.data))` for the example above (or np.ascontiguousarray for C contiguousness).

Another option might be to allow arbitrary `**kwargs` which will be passed through as-is to the `astype` method of the underlying array and making it the responsibility of the user to only supply parameters which make sense for that particular array type.

What are your thoughts? Does xarray have some kind of policy for supporting parameters which might not make sense for all types of duck arrays?
@rhkleijn thanks for your thoughtful comment.

> Does xarray have some kind of policy for supporting parameters which might not make sense for all types of duck arrays?

Not AFAIK but it would be good to have one. 

> Another option might be to allow arbitrary **kwargs which will be passed through as-is to the astype method of the underlying array and making it the responsibility of the user to only supply parameters which make sense for that particular array type.

I think this is a good policy.

Another option would be to copy the numpy signature with default `None`
```
def astype(dtype, order=None, casting=None, subok=None, copy=None)
```
and only forward kwargs that are `not None`. This has the advantage of surfacing all available parameters in xarray's documentation, but the default value would not be documented. It seems like only a small improvement over following your proposal and linking to `numpy.ndarray.astype` in the docstring

PS: The "special case" logic in astype will be removed, it was added as a temporary fix to preserve backward compatibility.

That is a nicer solution. Never contributed a PR before, but I'll try to work on this next week. It looks like a good first issue.
I will also include xarray's recently added `keep_attrs` argument. Since the signature has been in flux both in version 0.16.1 and now again I intend to make all arguments following `dtype` keyword-only in order to avoid introducing unnoticed bugs when user code calls it with positional arguments.

``def astype(self, dtype, *, order=None, casting=None, subok=None, copy=None, keep_attrs=True)``
Working on a unit test for the `subok` argument I found no way for creating a DataArray backed by a subclass of `np.ndarray` (even with NEP 18 enabled). 

The DataArray constructor calls `xr.core.variable.as_compatible_data`. This function:

- converts `np.ma` instances to `np.ndarray` with fill values applied.  
- the NEP 18 specific branch which would keep the supplied `data` argument (and its type) is not reachable for (subclasses of) `np.ndarray`
- it converts these subclasses to `np.ndarray`. 

Is this behaviour intentional? 

What to do with `astype`? If the behaviour is not intentional we could add the `subok` unit test but marked as xfail until that is fixed. If it is intentional we could omit the `subok` argument here.