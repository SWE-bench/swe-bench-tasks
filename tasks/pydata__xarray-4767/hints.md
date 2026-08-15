> ds.transpose('not_existing_dim', 'lat', 'lon', 'time', ...)

IMO this should raise an error too
> > ds.transpose('not_existing_dim', 'lat', 'lon', 'time', ...)
> 
> IMO this should raise an error too

I actually like it handling non_existing_dims automatically; maybe could be keyword though:
`ds.transpose('not_existing_dim', 'lat', 'lon', 'time', ..., errors='ignore')`
Yes i think `missing_dims="ignore"` would be great. This would match the kwarg in `isel` (https://xarray.pydata.org/en/stable/generated/xarray.Dataset.isel.html)
Hey! Can I work on this?
Sure.

On Sat, Jan 2, 2021, 6:38 AM Daniel Mesejo-León <notifications@github.com>
wrote:

> Hey! Can I work on this?
>
> —
> You are receiving this because you authored the thread.
> Reply to this email directly, view it on GitHub
> <https://github.com/pydata/xarray/issues/4647#issuecomment-753468760>, or
> unsubscribe
> <https://github.com/notifications/unsubscribe-auth/ADU7FFVUS2TTAA6MRGX5G73SX4HSRANCNFSM4UMKLBWQ>
> .
>

Hey, I was working on this and notice that transpose uses the method `infix_dims` to resolve the Ellipsis, should I put the expected behavior on `infix_dims` or only on transpose? The method `infix_dims` is also used in [variable.transpose](https://github.com/pydata/xarray/blob/8039a954f0f04c683198687aaf43423609774a0c/xarray/core/variable.py#L1401) and in [variable._stack_once](https://github.com/pydata/xarray/blob/8039a954f0f04c683198687aaf43423609774a0c/xarray/core/variable.py#L1490). For me it seems right to put the new behavior on `infix_dims` to keep the behavior uniform, but I would like to know your opinion. 

As a side-note I also noted that the return value of `infix_dims` is an iterator but on every usage is either converted to tuple or list, should I change the return value or keep it as it is?
Yes, agree this should be changed in `infix_dims`. 

Fine to update the return type if it changes, but no need to coerce it premptively. 

Thanks!