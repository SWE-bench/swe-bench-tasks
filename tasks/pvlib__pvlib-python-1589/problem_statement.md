ZeroDivisionError when gcr is zero
**Describe the bug**

Though maybe not intuitive, setting ground coverage ratio to zero is useful when a plant consists of a single shed, e.g. calculating the irradiance on the backside of the panels. However, e.g., `bifacial.infinite_sheds.get_irradiance_poa` fails with `ZeroDivisionError` whenever `gcr=0`.

**To Reproduce**

```python
from pvlib.bifacial.infinite_sheds import get_irradiance_poa

get_irradiance_poa(surface_tilt=160, surface_azimuth=180, solar_zenith=20, solar_azimuth=180, gcr=0, height=1, pitch=1000, ghi=200, dhi=200, dni=0, albedo=0.2)
```
returns:
```
Traceback (most recent call last):
  File "C:\Python\Python310\lib\site-packages\IPython\core\interactiveshell.py", line 3398, in run_code
    exec(code_obj, self.user_global_ns, self.user_ns)
  File "<ipython-input-7-0cb583b2b311>", line 3, in <cell line: 3>
    get_irradiance_poa(surface_tilt=160, surface_azimuth=180, solar_zenith=20, solar_azimuth=180, gcr=0, height=1, pitch=1, ghi=200, dhi=200, dni=0, albedo=0.2)
  File "C:\Python\Python310\lib\site-packages\pvlib\bifacial\infinite_sheds.py", line 522, in get_irradiance_poa
    vf_shade_sky, vf_noshade_sky = _vf_row_sky_integ(
  File "C:\Python\Python310\lib\site-packages\pvlib\bifacial\infinite_sheds.py", line 145, in _vf_row_sky_integ
    psi_t_shaded = masking_angle(surface_tilt, gcr, x)
  File "C:\Python\Python310\lib\site-packages\pvlib\shading.py", line 56, in masking_angle
    denominator = 1/gcr - (1 - slant_height) * cosd(surface_tilt)
ZeroDivisionError: division by zero
```

**Expected behavior**

One can easily solve this `ZeroDivisionError` by multiplying both numerator and denominator with `gcr` inside `shading.masking_angle` and the same inside `bifacial.infinite_sheds._ground_angle`.

**Versions:**
 - ``pvlib.__version__``: '0.9.3'
 - ``pandas.__version__``: '1.4.4'
 - python: '3.10.4'

