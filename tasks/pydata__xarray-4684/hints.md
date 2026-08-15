This has something to do with the time values at some point being a float:

```python
>>> import numpy as np
>>> np.datetime64("2017-02-22T16:24:10.586000000").astype("float64").astype(np.dtype('<M8[ns]'))
numpy.datetime64('2017-02-22T16:24:10.585999872')
```

It looks like this is happening somewhere in the [cftime](https://github.com/Unidata/cftime/blob/master/cftime/_cftime.pyx#L870) library.
Thanks for the report @half-adder.

This indeed is related to times being encoded as floats, but actually is not cftime-related (the times here not being encoded using cftime; we only use cftime for non-standard calendars and out of nanosecond-resolution bounds dates).  

Here's a minimal working example that illustrates the issue with the current logic in [`coding.times.encode_cf_datetime`](https://github.com/pydata/xarray/blob/69548df9826cde9df6cbdae9c033c9fb1e62d493/xarray/coding/times.py#L343-L389):
```
In [1]: import numpy as np; import pandas as pd

In [2]: times = pd.DatetimeIndex([np.datetime64("2017-02-22T16:27:08.732000000")])

In [3]: reference = pd.Timestamp("1900-01-01")

In [4]: units = np.timedelta64(1, "us")

In [5]: (times - reference).values[0]
Out[5]: numpy.timedelta64(3696769628732000000,'ns')

In [6]: ((times - reference) / units).values[0]
Out[6]: 3696769628732000.5
```
In principle, we should be able to represent the difference between this date and the reference date in an integer amount of microseconds, but timedelta division produces a float.  We currently [try to cast these floats to integers when possible](https://github.com/pydata/xarray/blob/69548df9826cde9df6cbdae9c033c9fb1e62d493/xarray/coding/times.py#L388), but that's not always safe to do, e.g. in the case above.

It would be great to make roundtripping times -- particularly standard calendar datetimes like these -- more robust.  It's possible we could now leverage [floor division (i.e. `//`) of timedeltas within NumPy](https://github.com/numpy/numpy/pull/12308) for this (assuming we first check that the unit conversion divisor exactly divides each timedelta; if it doesn't we'd fall back to using floats):

```
In [7]: ((times - reference) // units).values[0]
Out[7]: 3696769628732000
```
These precision issues can be tricky, however, so we'd need to think things through carefully.  Even if we fixed this on the encoding side, [things are converted to floats during decoding](https://github.com/pydata/xarray/blob/69548df9826cde9df6cbdae9c033c9fb1e62d493/xarray/coding/times.py#L125-L132), so we'd need to make a change there too.
Just stumbled upon this as well. Internally, `datetime64[ns]` is simply an 8-byte int. Why on earth would it be serialized in a lossy way as a float64?...

Simply telling it to `encoding={...: {'dtype': 'int64'}}` won't work since then it complains about serializing float as an int.

Is there a way out of this, other than not using `M8[ns]` dtypes at all with xarray?

This is a huge issue, as anyone using nanosecond-precision timestamps with xarray would unknowingly and silently read wrong data after deserializing.
> Internally, datetime64[ns] is simply an 8-byte int. Why on earth would it be serialized in a lossy way as a float64?...

The short answer is that [CF conventions allow for dates to be encoded with floating point values](https://cfconventions.org/Data/cf-conventions/cf-conventions-1.8/cf-conventions.html#time-coordinate), so we encounter that in data that xarray ingests from other sources (i.e. files that were not even produced with Python, let alone xarray).  If we didn't have to worry about roundtripping files that followed those conventions, I agree we would just encode everything with nanosecond units as `int64` values.  

> This is a huge issue, as anyone using nanosecond-precision timestamps with xarray would unknowingly and silently read wrong data after deserializing.

Yes, I can see why this would be quite frustrating.  In principle we should be able to handle this (contributions are welcome); it just has not been a priority up to this point.  In my experience xarray's current encoding and decoding methods for standard calendar times work well up to at least second precision.
Can we use the `encoding["dtype"]` field to solve this? i.e. use `int64` when `encoding["dtype"]` is not set and use the specified value when available?
> In principle we should be able to handle this (contributions are welcome)

I don't mind contributing but not knowing the netcdf stuff inside out I'm not sure I have a good vision on what's the proper way to do it. My use case is very simple - I have an in-memory xr.Dataset that I want to save() and then load() without losses.

Should it just be an `xr.save(..., m8=True)` (or whatever that flag would be called), so that all of numpy's `M8[...]` and `m8[...]` would be serialized transparently (as int64, that is) without passing them through the whole cftime pipeline. It would be then nice, of course, if `xr.load` was also aware of this convention (via some special attribute or somehow else) and could convert them back like `.view('M8[ns]')` when loading. I think xarray should also throw an exception if it detects timestamps/timedeltas of nanosecond precision that it can't serialize without going through int-float-int routine (or automatically revert to using this transparent but netcdf-incompatible mode).

Maybe this is not the proper way to do it - ideas welcome (there's also an open PR - #4400 - mind checking that out?)
> Can we use the encoding["dtype"] field to solve this? i.e. use int64 when encoding["dtype"] is not set and use the specified value when available?

I think a lot of logic needs to be reshuffled, because as of right now it will complain "you can't store a float64 in int64" or something along those lines, when trying to do it with a nanosecond timestamp.
I would look here: https://github.com/pydata/xarray/blob/255bc8ee9cbe8b212e3262b0d4b2e32088a08064/xarray/coding/times.py#L440-L474