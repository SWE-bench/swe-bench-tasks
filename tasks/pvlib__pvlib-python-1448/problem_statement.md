Output of solarposition.sun_rise_set_transit_ephem depends on installed ephem version
**Describe the bug**
`pvlib.solarposition.sun_rise_set_transit_ephem` returns a different answer depending on what version of `ephem` is installed. I think the problem is that our wrapper assumes that ephem doesn't pay attention to timezone localization, so it converts the timestamp components to UTC but doesn't bother to change the timestamp's tzinfo:

https://github.com/pvlib/pvlib-python/blob/8d0f863da92739669e01ac4da4145e4547638b50/pvlib/solarposition.py#L577-L579

However, starting in `ephem==4.1.1` the timezone is no longer ignored ([ref](https://rhodesmill.org/pyephem/CHANGELOG.html#version-4-1-1-2021-november-27)), so the UTC offset is applied twice.  This can shift the timestamp into the next solar period and return the rise/set/transit for the wrong day. 


**To Reproduce**
See how the returned sunrise differs by ~24 hours (2019-01-01 vs 2019-01-02) here:

```python
import pandas as pd
import pvlib
times = pd.date_range('2019-01-01', freq='h', periods=1, tz='Etc/GMT+8')
out = pvlib.solarposition.sun_rise_set_transit_ephem(times, 40, -120)
print(out.T)
```

#### `ephem==4.0.0.1`:
```

               2019-01-01 00:00:00-08:00
sunrise 2019-01-01 07:21:28.793036-08:00
sunset  2019-01-01 16:45:50.959086-08:00
transit 2019-01-01 12:03:35.730674-08:00
```

#### `ephem==4.1.2`:
```
               2019-01-01 00:00:00-08:00
sunrise 2019-01-02 07:21:35.237404-08:00
sunset  2019-01-01 16:45:50.947472-08:00
transit 2019-01-01 12:03:35.728413-08:00
```

**Expected behavior**
pvlib should give ephem timestamps consistent with its input requirements.  Replacing the above manual utc offset subtraction (which leaves the original tzinfo in place) with `thetime.astimezone(pytz.UTC)` may be suitable for both old and new versions of ephem.  I don't ever use pytz and python datetimes so maybe there's a better alternative.

**Versions:**
 - ``pvlib.__version__``: 0.9.1
 - python: 3.7

**Additional context**
This difference would have popped up back in November when ephem 4.1.1 was released had it not been for #1447.  Here's an example failure: https://dev.azure.com/solararbiter/pvlib%20python/_build/results?buildId=6027&view=logs&j=e1592cb8-2816-5754-b393-3839a187d454&t=377c4fd6-97bd-5996-bc02-4d072a8786ea&l=2267

