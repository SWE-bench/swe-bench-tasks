For shift intervals that can be represented as timedeltas this seems reasonably straightforward to add.  I would hold off for monthly or annual intervals -- even for 360-day calendars, I don't think that non-integer shift factors are very well-defined in that context, since those frequencies involve rounding, e.g. to the beginnings or ends of months:
```
In [2]: times = xr.cftime_range("2000", freq="7D", periods=7)

In [3]: times
Out[3]:
CFTimeIndex([2000-01-01 00:00:00, 2000-01-08 00:00:00, 2000-01-15 00:00:00,
             2000-01-22 00:00:00, 2000-01-29 00:00:00, 2000-02-05 00:00:00,
             2000-02-12 00:00:00],
            dtype='object', length=7, calendar='gregorian', freq='7D')

In [4]: times.shift(2, "M")
Out[4]:
CFTimeIndex([2000-02-29 00:00:00, 2000-02-29 00:00:00, 2000-02-29 00:00:00,
             2000-02-29 00:00:00, 2000-02-29 00:00:00, 2000-03-31 00:00:00,
             2000-03-31 00:00:00],
            dtype='object', length=7, calendar='gregorian', freq='None')
```