I haven't profiled it but I suspect you are right: [this line](https://github.com/pvlib/pvlib-python/blob/7bb30ad6e9d599d10510c7b37d95d56f14e846b4/pvlib/bifacial/infinite_sheds.py#L61) is the likely bottleneck.
@wholmgren in #1627 you mentioned looking into optimizations for infinite sheds.  I wonder if there is anything in the works?

Also here's a quick and dirty profile, for reference:

![image](https://user-images.githubusercontent.com/57452607/222270556-923deda6-6b9a-4006-b729-6270f0235d90.png)

```python
import pvlib
import pandas as pd

times = pd.date_range('2019-01-01', '2019-02-01', freq='5T', tz='Etc/GMT+5')
location = pvlib.location.Location(40, -80)
sp = location.get_solarposition(times)
cs = location.get_clearsky(times, solar_position=sp)
tr = pvlib.tracking.singleaxis(sp.zenith, sp.azimuth)

gcr = 0.5
height = 1.5
pitch = 3.0
albedo = 0.2

result = pvlib.bifacial.infinite_sheds.get_irradiance(
    surface_tilt=tr.surface_tilt, surface_azimuth=tr.surface_azimuth,
    solar_zenith=sp.zenith, solar_azimuth=sp.azimuth,
    gcr=0.5, height=1.5, pitch=3.0,
    ghi=cs.ghi, dhi=cs.dhi, dni=cs.dni, albedo=0.2
)
```
I identified a few places with repeated calculations and started thinking about larger changes to mostly private functions that would avoid more repeated calculations. So all of that is largely complementary to vectorization.
This is a great conversation, thanks all for responding so quickly. Is there a timeline by which we could expect some of these perf changes to go in? Excited to use a faster Infinite Sheds. :)
I tried out vectorizing over `surface_tilt` in `utils._vf_ground_sky_2d` and got a ~15-20% speed improvement for `infinite_sheds._vf_ground_sky_integ`.  After those changes (and some minor unrelated optimizations), 80% of remaining runtime in `_vf_ground_sky_2d` is in the arctan and cosine calculations, so there might not be much room for additional improvement without changing how we do the math.  I'll open a PR with some more formal benchmark results. 

@aturabi, separately from these code optimizations, you might take a look at reducing the `npoints` parameter.  That parameter offers a trade-off between model resolution and speed, and I don't think we've done a real sensitivity analysis but I bet the default of 100 is overkill a lot of the time and you could get essentially the same simulation results faster with a lower (perhaps much lower) number.  