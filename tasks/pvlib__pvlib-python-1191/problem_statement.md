irradiance.aoi can return NaN when module orientation is perfectly aligned with solar position
**Describe the bug**
I was playing with a dual-axis tracking mount with #1176 and found that when the modules are perfectly aligned with the sun (i.e. AOI should be exactly zero), floating point round-off can result in aoi projection values slightly greater than one, resulting in NaN aoi.  This only happens for some perfectly-aligned inputs (for example tilt=zenith=20, azimuth=180 returns aoi=0 as expected).

**To Reproduce**
```python
import pvlib
zenith = 89.26778228223463
azimuth = 60.932028605997004
print(pvlib.irradiance.aoi_projection(zenith, azimuth, zenith, azimuth))
print(pvlib.irradiance.aoi(zenith, azimuth, zenith, azimuth))

# output:
1.0000000000000002
RuntimeWarning: invalid value encountered in arccos:  aoi_value = np.rad2deg(np.arccos(projection))
nan
```

**Expected behavior**
I expect aoi=0 whenever module orientation and solar position angles are identical.

**Versions:**
 - ``pvlib.__version__``: `0.9.0-alpha.4+14.g61650e9`
 - ``pandas.__version__``: `0.25.1`
 - ``numpy.__version__``: `1.17.0`
 - python: `3.7.7 (default, May  6 2020, 11:45:54) [MSC v.1916 64 bit (AMD64)]`

**Additional context**
Some ideas for fixes:
1) In `irradiance.aoi_projection`, return a hard-coded `1.0` for inputs within some small tolerance
2) In `irradiance.aoi_projection`, clamp return value to `[-1, +1]`
3) In `irradiance.aoi`, clamp aoi_projection values to `[-1, +1`] before calling `arccos`
4) Rework the `irradiance.aoi_projection` trig equations to not generate impossible values?
