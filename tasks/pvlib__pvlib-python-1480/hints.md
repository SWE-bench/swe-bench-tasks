I like this. 

This is related to an issue submitted for NREL SAM, https://github.com/NREL/SAM/issues/850, and I think @mjprilliman is looking at something related. 
@kanderso-nrel Nice meeting you at PVSC the other day.  I've been working on this a bit using the tilt and azimuth equations in the technical report by Bill Marion mentioned.  I would like to use this for the custom backtracking schedules Nevados generates for the terrain following trackers.  

I have surface tilt working.  It requires a dataframe `df` of axis tilt angles. I use the dataframe because Nevados has a different axis tilt for each bay in our tracker.  stdf (surface tilt dataframe) starts as a dataframe of rotation angles (theta) indexed by timestep and is transformed into surface tilts.  col.name is used to match the tracker and bay's rotation angle to their corresponding axis tilt.

```
        def calc_surface_tilt(col):
            axis_tilt = df.at[col.name, 'axis_tilt']
            surface_tilt = np.rad2deg(
                np.arccos(
                    np.cos(np.deg2rad(col)) * np.cos(np.deg2rad(axis_tilt))
                )
            )
            return surface_tilt

        stdf = stdf.apply(calc_surface_tilt, axis=0)
```

Unfortunately I can't seem to get surface azimuth working correctly.  sadf (surface angle data frame) is almost equal to surface azimuth as calculated by pvlib, but not quite in the middle of the day.  `ts2` is the output of `pvlib.tracking.singleaxis`


```
    sadf = np.rad2deg(
        np.deg2rad(180) +
        np.arcsin(
            (
                np.sin(np.deg2rad(ts2['tracker_theta'])) /
                np.sin(np.deg2rad(ts2['surface_tilt']))
            ).clip(upper=1, lower=-1)
        )
    )
```
![image](https://user-images.githubusercontent.com/33131958/174192086-124a53c6-78c3-445c-a50d-3a70f6944adb.png)

![image](https://user-images.githubusercontent.com/33131958/174192355-62437cb6-9f23-403f-ab26-21924d79dab7.png)



Thanks @kurt-rhee for this investigation.  Trying some simple examples on my end, things seem to line up.  Here's a complete copy/pasteable example where I get negligible difference between the current pvlib approach and your code.  Note that I did replace the hard-coded axis_azimuth of 180 in the surface_azimuth calculation. 

<details>
  <summary>Click to expand!</summary>

```python
import pvlib
import pandas as pd
import numpy as np

axis_tilt = 20
axis_azimuth = 230
loc = pvlib.location.Location(40, -80)
times = pd.date_range('2019-06-01', '2019-06-02', freq='5T', tz='Etc/GMT+5')
sp = loc.get_solarposition(times)
tr = pvlib.tracking.singleaxis(sp.apparent_zenith, sp.azimuth,
                               axis_tilt=axis_tilt, axis_azimuth=axis_azimuth)


def rotation_to_orientation(tracker_theta, axis_tilt=0, axis_azimuth=0, max_angle=90):
    surface_tilt = np.rad2deg(
        np.arccos(
            np.cos(np.deg2rad(tracker_theta)) * np.cos(np.deg2rad(axis_tilt))
        )
    )
    surface_azimuth = np.rad2deg(
        np.deg2rad(axis_azimuth) +
        np.arcsin(
            (
                np.sin(np.deg2rad(tracker_theta)) /
                np.sin(np.deg2rad(surface_tilt))
            ).clip(upper=1, lower=-1)
        )
    )
    return pd.DataFrame({
        'tracker_theta': tracker_theta,
        'surface_tilt': surface_tilt,
        'surface_azimuth': surface_azimuth,
    })

tr2 = rotation_to_orientation(tr.tracker_theta, axis_tilt=axis_tilt, axis_azimuth=axis_azimuth)
```

</details>

```python
In [53]: (tr[['surface_tilt', 'surface_azimuth']] - tr2[['surface_tilt', 'surface_azimuth']]).describe()
Out[53]: 
       surface_tilt  surface_azimuth
count  1.780000e+02     1.780000e+02
mean  -6.586492e-16     3.193450e-15
std    8.916369e-15     2.864187e-14
min   -2.842171e-14    -5.684342e-14
25%   -7.105427e-15     0.000000e+00
50%    0.000000e+00     0.000000e+00
75%    3.552714e-15     2.842171e-14
max    2.131628e-14     5.684342e-14
```
Not that there was much doubt, but I've convinced myself that Bill's surface orientation equations are mathematically equivalent to the approach pvlib takes.  Here are some notes if anyone is interested: https://gist.github.com/kanderso-nrel/ac3051de41261df317180c794144d6a9

If we do switch to Bill's equations we should be sure to preserve the handling of NaN and edge cases of the current implementation.
I realize that my small error metric is due to a small timeshift that I had in my data that changed my answer when resampling / averaging. 

Cheers