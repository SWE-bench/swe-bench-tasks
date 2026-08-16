@kdebrab thanks for investigating this case, which wasn't consider in the implementation. @pvlib/pvlib-core I think we should fix this. 

For consistency we should also extend `shading.masking_angle_passias` for the limiting case of `gcr=0`. That may be more complicated and could be done in a second PR.

I think `infinite_sheds.get_irradiance_poa(...)` converges to `irradiance.get_total_irradiance(..., model='isotropic')` as gcr approaches zero, so that's an option for modeling this situation in the meantime.  
Probably close enough to be useful, but in theory the rear irradiance would be slightly less than GHI * 1/2 (1 - cos(tilt)), due to the row's shadow.
With a more realistic model (e.g. pvfactors) that considers shadows individually that's true, but `infinite_sheds` models ground-reflected irradiance using integrated averages which dilute the effect of the row's own shadow to nothing as gcr approaches zero.  By decreasing `gcr` and increasing `npoints` you can get `infinite_sheds` as close to `get_total_irradiance` as you like:

![image](https://user-images.githubusercontent.com/57452607/198049857-0c844116-3bc0-48dd-b889-8b658f39b4a0.png)

<details>
  <summary>Source</summary>

```python
import pvlib
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

times = pd.date_range('2019-06-01', '2019-06-02', freq='T', tz='Etc/GMT+5')
location = pvlib.location.Location(40, -80)
sp = location.get_solarposition(times)
cs = location.get_clearsky(times, solar_position=sp)

kwargs = dict(
    surface_tilt=20, surface_azimuth=180,
    solar_zenith=sp.apparent_zenith, solar_azimuth=sp.azimuth,
    ghi=cs.ghi, dhi=cs.dhi, dni=cs.dni, albedo=0.2
)

limit = pvlib.irradiance.get_total_irradiance(**kwargs, model='isotropic')['poa_global']

all_stats = []

for gcr in [0.3, 0.1, 1e-2, 1e-3, 1e-4, 1e-5, 1e-6, 1e-7]:
    stats = dict(gcr=gcr)
    for npoints in [100, 1000, 10000]:
        out = pvlib.bifacial.infinite_sheds.get_irradiance_poa(gcr=gcr, height=1, pitch=1/gcr, npoints=npoints, **kwargs)
        stats[f'npoints={npoints}'] = np.max(np.abs(out['poa_global'] - limit))

    all_stats.append(stats)

pd.DataFrame(all_stats).set_index('gcr').plot(logx=True, logy=True)
plt.ylabel('Max Absolute Difference [W/m2]')

```
</details>
@kanderso-nrel Thanks for pointing this out!

I think for a `surface_tilt` equal to 20° (front side of the panel) this result would be fine, as there is no shadow on the front surface from the own row. However, changing `surface_tilt` to 160° (back side of the panel) yields basically the same figure and that is indeed not ideal (and unexpected for me).

If I understand well, this is due to the calculation of the ground-reflected irradiance, where the infinite_sheds method uses (1) the **average** 'view factor from the ground to the sky' of the ground between the rows, and (2) the **average** 'fraction of ground between rows that is unshaded', both of which approach 1 as the pitch approaches infinity.

I think an improved method would not take the average, but some kind of weighted average, considering that the reflection from the ground right in front of the surface is more important than the reflection from the ground further away from the surface. In that case, I would assume that the effect of the row's own shadow would no longer dilute when gcr approaches zero.
> However, changing surface_tilt to 160° (back side of the panel) yields basically the same figure and that is indeed not ideal (and unexpected for me).

Oops, I think I had originally started with rear-side, switched to front-side just to check it as well, and forgot to switch back to rear before posting here.  Good catch.

FYI pvfactors (`pvlib.bifacial.pvfactors.pvfactors_timeseries`) can model irradiance for single rows (`n_pvrows=1, index_observed_pvrow=0`) and does not suffer from the averaging issues you mention. 