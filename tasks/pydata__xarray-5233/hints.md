1. exists as `ds.time.to_index().calendar`
2. would like to use
@aaronspring Oh, I didn't think of that trick for 1, thanks! But again, this fails with numpy-backed time coordinates. With the definition of a "default" calendar, there could be a more general way.
Thanks for opening up this discussion @aulemahal!  It's great to see the boundaries being pushed on what can be done with cftime dates in xarray.

> 1. `ds.time.dt.calendar` would be magic

I think something like this would be cool too (see the end of https://github.com/pydata/xarray/pull/4092#discussion_r439101051).  Attributes on the `dt` accessor normally return DataArrays with the same shape as the original, as opposed to scalar values, but it might be reasonable to make an exception in this case.  Xarray, and CF conventions for that matter, are written in a way that assume that all dates in an array have the same calendar type, and therefore returning an array filled with the same calendar name feels far inferior to returning a scalar.

> 2. `xr.convert_calendar(ds, "new_cal")` could be nice?

Both `convert_calendar` and `interp_calendar` seem like very nice utilities.  I have been fortunate enough not to have been in a situation to need something like those, but both of those methods seem like sensible and general approaches to the problem of converting a dataset from one calendar to another.  I have seen this as an issue for others, e.g. [this SO question](https://stackoverflow.com/questions/66188904/ways-to-resample-non-standard-cftimeindex-calendars-360-day-no-leap-year-with/66195199?noredirect=1#comment117035233_66195199), so I think we could be open to adding both to xarray.

> 3. `xr.date_range(start, stop, calendar=cal)`, same as pandas' (see context below).

We actually considered something like this in the initial stages of writing `cftime_range`, but decided against it, https://github.com/pydata/xarray/pull/2301#issuecomment-407087972, https://github.com/pydata/xarray/pull/2301#discussion_r217577759.  Maybe it is worth re-opening discussion about a possible more generic `xarray.date_range` function, though.

Using the calendar argument, as opposed to the range of the dates, to decide what type to return is a slightly different twist than what was discussed previously. I don't know how I feel about that. On one hand I can see why it would be convenient, but on the other hand `"default"` is not a valid CF calendar name so it feels a little strange to allow that as a special option to signal you want NumPy dates as a result.  I wonder if instead we handled this in a way similar to decoding times, where we have a `use_cftime` argument? Basically you would have `xarray.date_range(..., use_cftime=use_cftime)`, where:
- If `use_cftime` were set to `False` it would only return NumPy dates and error if this was not possible
- If `use_cftime` were set to `None` (default) it would return NumPy dates if the calendar and time range allowed; otherwise it would return cftime dates
- And if `use_cftime` were set to `True` it would only return cftime dates.

Would that work for your use-case?
Cool! I started a branch, will push a PR soon.

I understand the "default" issue  and using `use_cftime=None` makes sense to me!

~For `dt.calendar` and `date_range`, there remains the question on how we name numpy's calendar:
Python uses what CF conventions call `proleptic_gregorian`, but the default and most common calendar we see and use is CF's "standard".  May be users would expect "standard"?
A solution would be to check if the earliest value in the array is before 1582-10-15. If yes, return "proleptic_gregorian", if not, return "standard".~
Edited the comment above as I realized that numpy /pandas / xarray use nanoseconds by default, so the earliest date possible is 1677-09-21 00:12:43.145225. 
Thus, I suggest we return "standard" as the calendar of numpy-backed datetime indexes.