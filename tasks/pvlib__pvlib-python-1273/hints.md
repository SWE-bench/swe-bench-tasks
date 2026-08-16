I agree that `abs` looks like a problem.
This is an ancient line first committed April 3, 2015:
https://github.com/pvlib/pvlib-python/blob/46f69bf9ae2869d75f74664684b4de3b3b3e9bf2/pvlib/tracking.py#L219
Yes, my initial port of the matlab code was as close to 1:1 as I could make it. I don't recall second guessing the `abs` at the time, but I certainly should have.
We (Dan and I) concluded that line is in error, in the matlab code.
Should we just replace that entire line with a call to `irradiance.aoi`?
@kanderso-nrel the shortcoming with using `irradiance.aoi` afaict is that it calls [`irradiance.aoi_projection`](https://github.com/pvlib/pvlib-python/blob/0e6fea6219618c0da944e6ed686c10f5b1e244a2/pvlib/irradiance.py#L153) which is redundant because the single axis tracker already calculates the solar vector and rotates it into the tracker reference frame to use the `x` and `z` components to calculate the tracker rotation. 

COINCIDENTALLY, `irradiance.aoi` is already used in the `SingleAzisTracker` method `get_aoi` which afaict should be a static or class method because it NEVER uses self. I guess that's a separate issue. Anyway, it says this method isn't necessary, b/c `singleaxis` already returns AOI.

ALSO, I was thrown for a bit in `irradiance.aoi_projection` which doesn't have a lot of commentary, because when calculating the dot product of surface normal and solar vector, it shows `z=cos(tilt)*cos(ze)` first and `x=sin(tilt)*sin(ze)*cos(az-surfaz)` last. Whatever

Anyway, back to this, should we consider adjusting `irradiance.aoi` to allow the user to pass in the AOI projection as an alternate parameter? Seems a bit like a hacky workaround, but something like this:

```python
# in irradiance.py
def aoi(surface_tilt, surface_azimuth, solar_zenith, solar_azimuth,
       projection=None):
    if projection is None:
        projection = aoi_projection(
            surface_tilt, surface_azimuth, solar_zenith, solar_azimuth)
    # from here it's the same
    aoi_value = np.rad2deg(np.arccos(projection))
    ...
```

then in `singleaxis` we change it to this:

```python
    # calculate angle-of-incidence on panel
    # aoi = np.degrees(np.arccos(np.abs(np.sum(sun_vec*panel_norm, axis=0))))
    projection = (xp * panel_norm[0]
                  + yp * panel_norm[1]
                  + zp * panel_norm[2])
    # can't use np.dot for 2D matrices
    # expanding arrays is about 1.5x faster than sum
    # can skip sun_vec array formation, but still need panel norm for later
    aoi = irradiance.aoi(None, None, None, None, projection=projection)
```
or maybe just to get this ball roling we use clip for now and just close it with a #TODO