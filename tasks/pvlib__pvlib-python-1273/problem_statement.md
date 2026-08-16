Incorrect AOI from pvlib.tracking.singleaxis
`pvlib.tracking.singleaxis` produces an incorrect AOI when the sun is above the earth horizon but behind the module plane.

**To Reproduce**
Model a fixed tilt system (90 tilt, 180 azimuth) and compare to a vertical single axis tracker with very small rotation limit.

```

import pandas as pd
import pytz
import pvlib
from matplotlib import pyplot as plt

loc = pvlib.location.Location(40.1134, -88.3695)

dr = pd.date_range(start='02-Jun-1998 00:00:00', end='02-Jun-1998 23:55:00',
                   freq='5T')
tz = pytz.timezone('Etc/GMT+6')
dr = dr.tz_localize(tz)
hr = dr.hour + dr.minute/60

sp = loc.get_solarposition(dr)

cs = loc.get_clearsky(dr)

tr = pvlib.tracking.singleaxis(sp['apparent_zenith'], sp['azimuth'],
                               axis_tilt=90, axis_azimuth=180, max_angle=0.01,
                               backtrack=False)

fixed = pvlib.irradiance.aoi(90, 180, sp['apparent_zenith'], sp['azimuth'])

plt.plot(hr, fixed)
plt.plot(hr, tr['aoi'])
plt.plot(hr, sp[['apparent_elevation']])
plt.show()

plt.legend(['aoi - fixed', 'aoi - tracked', 'apparent_elevation'])
```

**Expected behavior**
The AOI for the fixed tilt system shows values greater than 90 when the sun is behind the module plane. The AOI from `singleaxis` does not.

I think the source of the error is the use of `abs` in [this ](https://github.com/pvlib/pvlib-python/blob/ca61503fa83e76631f84fb4237d9e11ae99f3c77/pvlib/tracking.py#L446)line.

**Screenshots**
![aoi_fixed_vs_tracked](https://user-images.githubusercontent.com/5393711/117505270-01087a80-af41-11eb-9220-10cccf2714e1.png)


**Versions:**
 - ``pvlib.__version__``: 0.8.1

First reported by email from Jim Wilzcak (NOAA) for the PVlib Matlab function [pvl_singleaxis.m](https://github.com/sandialabs/MATLAB_PV_LIB/blob/master/pvl_singleaxis.m)

