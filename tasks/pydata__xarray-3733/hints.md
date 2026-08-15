dask has `lstsq` https://docs.dask.org/en/latest/array-api.html#dask.array.linalg.lstsq . Would that avoid the dimension-must-have-one-chunk issue?

EDIT: I am in favour of adding this. It's a common use case like `differentiate` and `integrate`
I am in favour of adding this (and other common functionality), but I would comment that perhaps we should move forward with discussion about where to put extra functionality generally (the scipy to xarray's numpy if you will)? If only because otherwise the API could get to an unwieldy size? 

I can't remember where the relevant issue was, but for example this might go under an `xarray.utils` module?
I second @TomNicholas' point... functionality like this would be wonderful to have but where would be the best place for it to live?
The question of a standalone library has come up many times (see discussion in #1850). Everyone agrees it's a nice idea, but no one seems to have the bandwidth to take on ownership and maintenance of such a project.

Perhaps we need to put this issue on pause and figure out a general strategy here. The current Xarray API is far from a complete feature set, so more development is needed. But we should decide what belongs in xarray and what belongs elsewhere. #1850 is probably the best place to continue that conversation.
The quickest way to close this is probably to extend @fujiisoup's xr-scipy(https://github.com/fujiisoup/xr-scipy) to wrap `scipy.linalg.lstsq` and `dask.array.linalg.lstsq`. It is likely that all the necessary helper functions already exist.
Now that xarray itself has interpolate, gradient, and integrate, it seems like the only thing left in xr-scipy is fourier transforms, which is also what we provide in [xrft](https://github.com/xgcm/xrft)! 😆 
From a user perspective, I think people prefer to find stuff in one place.

From a maintainer perspective, as long as it's somewhat domain agnostic (e.g., "physical sciences" rather than "oceanography") and written to a reasonable level of code quality, I think it's fine to toss it into xarray. "Already exists in NumPy/SciPy" is probably a reasonable proxy for the former.

So I say: yes, let's toss in polyfit, along with fast fourier transforms.

If we're concerned about clutter, we can put stuff in a dedicated namespace, e.g., `xarray.wrappers`.
https://xscale.readthedocs.io/en/latest/generated/xscale.signal.fitting.polyfit.html#xscale.signal.fitting.polyfit
I'm getting deja-vu here... Xscale has a huge and impressive sounding API. But no code coverage and no commits since January. Like many of these projects, it seems to have bit off more than its maintainers could chew.

_Edit: I'd love for such a package to really achieve community uptake and become sustainable. I just don't quite know the roadmap for getting there._
It seems like these are getting reinvented often enough that it's worth
pulling some of these into xarray proper.

On Wed, Oct 2, 2019 at 9:04 AM Ryan Abernathey <notifications@github.com>
wrote:

> I'm getting deja-vu here... Xscale has a huge and impressive sounding API.
> But no code coverage and no commits since January. Like many of these
> projects, it seems to have bit off more than its maintainers could chew.
>
> —
> You are receiving this because you commented.
> Reply to this email directly, view it on GitHub
> <https://github.com/pydata/xarray/issues/3349?email_source=notifications&email_token=AAJJFVV5XANAGSPKHSF6KZLQMTA7HA5CNFSM4I3HCUUKYY3PNVWWK3TUL52HS4DFVREXG43VMVBW63LNMVXHJKTDN5WW2ZLOORPWSZGOEAFJCDI#issuecomment-537563405>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAJJFVREMUT5RKJJESG5NVLQMTA7HANCNFSM4I3HCUUA>
> .
>

xyzpy has a polyfit too : https://xyzpy.readthedocs.io/en/latest/manipulate.html
Started to work on this and facing some issues with the x-coordinate when its a datetime. For standard calendars, I can use `pd.to_numeric(da.time)`, but for non-standard calendars, it's not clear how to go ahead. If I use `xr.coding.times.encode_cf_datetime(coord)`, the coefficients we'll find will only make sense in the `polyval` function if we use the same time encoding. 


If I understand correctly, `pd.to_numeric` (and its inverse) works because it always uses 1970-01-01T00:00:00 as the reference date.  Could we do something similar when working with cftime dates?

Within xarray we typically convert dates to numeric values (e.g. when doing interpolation) using `xarray.core.duck_array_ops.datetime_to_numeric`, which takes an optional `offset` argument to control the reference date.  Would it work to always make sure to pass 1970-01-01T00:00:00 with the appropriate calendar type as the offset when constructing the ordinal x-coordinate for `polyfit`/`polyval`?
Thanks, it seems to work !
Excellent, looking forward to seeing it in a PR!
My current implementation is pretty naive. It's just calling numpy.polyfit using dask.array.apply_along_axis. Happy to put that in a PR as a starting point, but there are a couple of questions I had: 
* How to return the full output (residuals, rank, singular_values, rcond) ? A tuple of dataarrays or a dataset ?
* Do we want to use the dask least square functionality to allow for chunking within the x dimension ? Then it's not just a simple wrapper around polyfit. 
* Should we use np.polyfit or np.polynomial.polynomial.polyfit ?
[geocat.comp.ndpolyfit](https://geocat-comp.readthedocs.io/en/latest/user_api/generated/geocat.comp.ndpolyfit.html#geocat.comp.ndpolyfit) extends `NumPy.polyfit` for multi-dimensional arrays and has support for Xarray and Dask. It does exactly what is requested here.

regards,

@andersy005 @clyne @matt-long @khallock
@maboualidev Nice ! I see you're storing the residuals in the DataArray attributes. From my perspective, it would be useful to have those directly as DataArrays. Thoughts ?

So it looks like there are multiple inspirations to draw from. Here is what I could gather. 

- `xscale.signal.fitting.polyfit(obj, deg=1, dim=None, coord=None)` supports chunking along the fitting dimension using `dask.array.linalg.lstsq`. No explicit missing data handling.
- `xyzpy.signal.xr_polyfit(obj, dim, ix=None, deg=0.5, poly='hermite')` applies `np.polynomial.polynomial.polyfit` using `xr.apply_ufunc` along dim with the help of `numba`. Also supports other types of polynomial (legendre, chebyshev, ...). Missing values are masked out 1D wise. 
 - `geocat.comp.ndpolyfit(x: Iterable, y: Iterable, deg: int, axis: int = 0, **kwargs) -> (xr.DataArray, da.Array)` reorders the array to apply `np.polyfit` along dim, returns the full outputs (residuals, rank, etc) as DataArray attributes.  Missing values are masked out in bulk if possible, 1D-wise otherwise. 

There does not seem to be matching `polyval` implementations for any of those nor support for indexing along a time dimension with a non-standard calendar. 

Hi @huard Thanks for the reply.

Regarding:

> There does not seem to be matching polyval implementations for any of those nor support for indexing along a time dimension with a non-standard calendar.

There is a pull request on GeoCAT-comp for [ndpolyval](https://github.com/NCAR/geocat-comp/pull/49). I think `polyval` and `polyfit` go hand-in-hand. If we have `ndpolyfit` there must be a also a `ndpolyval`. 

Regarding:

> I see you're storing the residuals in the DataArray attributes. From my perspective, it would be useful to have those directly as DataArrays. Thoughts ?

I see the point and agree with you. I think it is a good idea to be as similar to `NumPy.polyfit` as possible; even for the style of the output. I will see it through to have that changed in GeoCAT.


attn: @clyne and @khallock
@maboualidev Is your objective to integrate the GeoCat implementation into xarray or keep it standalone ? 

On my end, I'll submit a PR to add support for non-standard calendars to `xarray.core.missing.get_clean_interp`, which you'd then be able to use to get x values from coordinates. 
> @maboualidev Is your objective to integrate the GeoCat implementation into xarray or keep it standalone ?

[GeoCAT](https://geocat.ucar.edu) is the python version of [NCL](https://www.ncl.ucar.edu) and we are a team at [NCAR](https://ncar.ucar.edu) working on it. I know that the team decision is to make use of Xarray within GeoCAT as much as possible, though. 


Currently the plan is to keep GeoCAT as a standalone package that plays well with Xarray.

> On Dec 16, 2019, at 9:21 AM, Mohammad Abouali <notifications@github.com> wrote:
> 
> @maboualidev Is your objective to integrate the GeoCat implementation into xarray or keep it standalone ?
> 
> GeoCAT is the python version of NCL and we are a team at NCAR working on it. I know that the team decision is to make use of Xarray within GeoCAT as much as possible, though.
> 
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub, or unsubscribe.
> 




@clyne Let me rephrase my question: how do you feel about xarray providing a polyfit/polyval implementation essentially duplicating GeoCat's implementation ? 
GeoCAT is licensed under Apache 2.0. So if someone wants to incorporate it into Xarray they are welcome to it :-)