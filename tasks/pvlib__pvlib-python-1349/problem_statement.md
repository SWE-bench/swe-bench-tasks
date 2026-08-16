`spectrum.spectrl2` calculates negative irradiance for angle of incidence outside +/- 90°
When using pvlib (but also the spectrl2 implementation provided by NREL), I obtain negative Irradiance for a north-facing panel.
From @kevinsa5 's [reply on StackOverflow](https://stackoverflow.com/questions/70172766/pvlib-bird1984-north-facing-element-shows-negative-irradiance/70174010#70174010) I take that this is in fact not intended.

In the example code below, the angle of incidence is calculated as values around 115°, so exceeding a possible (implicitly assumed) +/- 90° bound (sun behind panel).

This seems to be left open in the original report ([Bird & Riordan, 1984](https://www.nrel.gov/docs/legosti/old/2436.pdf)).

The direct irradiance `I_d` (*of a horizontal panel*, Eq 2-1) is obtained by multiplying by cosine of the sun zenith angle. I'd guess that setting that value strictly to zero for angles when cosZ is negative would not be too much of a stretch.

Then, the direct irradiance `I_d` goes into (Eq 3-18):

```
I_T(t) = I_d*cos(aoi) + I_s * ( (I_d*cos(aoi) / (H_0*D*cos(Z)) ) + 0.5*(1+cos(t)) * (1 - I_d/(H_0*D)) + 0.5 * I_T0 * r_g * (1-cos(t))
```

As such, when you view the angle of incidence `aoi` as the analogue of the sun zenith angle in the prior example, the two first terms of the diffuse irradiation (Eq 3-18) would become zero, which - again - for the direct irradiance would kind of make sense. What remains of (Eq 3-18) would be

```
I_T(t) = 0 + 0 + 0.5*(1+cos(t))*(1 - 0) + 0.5*I_T0*r_g*(1-cos(t))
```

I'm not from the field, so I'm very, very wary about the implications of such a work-around suggestion. Can anyone with a proper background comment on this? (Maybe it's the future of air conditioning :-D)


**MWE based on the tutorial below**

```python
## Using PV Lib

from pvlib import spectrum, solarposition, irradiance, atmosphere
import pandas as pd
import matplotlib.pyplot as plt

# assumptions from the technical report:
lat = 49.88
lon = 8.63
tilt = 45
azimuth = 0 # North = 0
pressure = 101300  # sea level, roughly
water_vapor_content = 0.5  # cm
tau500 = 0.1
ozone = 0.31  # atm-cm
albedo = 0.2

times = pd.date_range('2021-11-30 8:00', freq='h', periods=6, tz="Europe/Berlin") # , tz='Etc/GMT+9'
solpos = solarposition.get_solarposition(times, lat, lon)
aoi = irradiance.aoi(tilt, azimuth, solpos.apparent_zenith, solpos.azimuth)

# The technical report uses the 'kasten1966' airmass model, but later
# versions of SPECTRL2 use 'kastenyoung1989'.  Here we use 'kasten1966'
# for consistency with the technical report.
relative_airmass = atmosphere.get_relative_airmass(solpos.apparent_zenith,
                                                   model='kasten1966')

spectra = spectrum.spectrl2(
    apparent_zenith=solpos.apparent_zenith,
    aoi=aoi,
    surface_tilt=tilt,
    ground_albedo=albedo,
    surface_pressure=pressure,
    relative_airmass=relative_airmass,
    precipitable_water=water_vapor_content,
    ozone=ozone,
    aerosol_turbidity_500nm=tau500,
)

plt.figure()
plt.plot(spectra['wavelength'], spectra['poa_global'])
plt.xlim(200, 2700)
# plt.ylim(0, 1.8)
plt.title(r"2021-11-30, Darmstadt, $\tau=0.1$, Wv=0.5 cm")
plt.ylabel(r"Irradiance ($W m^{-2} nm^{-1}$)")
plt.xlabel(r"Wavelength ($nm$)")
time_labels = times.strftime("%H:%M %p")
labels = [
    "AM {:0.02f}, Z{:0.02f}, {}".format(*vals)
    for vals in zip(relative_airmass, solpos.apparent_zenith, time_labels)
]
plt.legend(labels)
plt.show()
```

![Figure_ne](https://user-images.githubusercontent.com/15192310/144224709-dea899e4-435e-4ff2-a3de-9e9524b28eb8.png)


