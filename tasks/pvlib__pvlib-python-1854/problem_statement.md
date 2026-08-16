PVSystem with single Array generates an error
**Is your feature request related to a problem? Please describe.**

When a PVSystem has a single Array, you can't assign just the Array instance when constructing the PVSystem.

```
mount = pvlib.pvsystem.FixedMount(surface_tilt=35, surface_azimuth=180)
array = pvlib.pvsystem.Array(mount=mount)
pv = pvlib.pvsystem.PVSystem(arrays=array)

---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
<ipython-input-13-f5424e3db16a> in <module>
      3 mount = pvlib.pvsystem.FixedMount(surface_tilt=35, surface_azimuth=180)
      4 array = pvlib.pvsystem.Array(mount=mount)
----> 5 pv = pvlib.pvsystem.PVSystem(arrays=array)

~\anaconda3\lib\site-packages\pvlib\pvsystem.py in __init__(self, arrays, surface_tilt, surface_azimuth, albedo, surface_type, module, module_type, module_parameters, temperature_model_parameters, modules_per_string, strings_per_inverter, inverter, inverter_parameters, racking_model, losses_parameters, name)
    251                 array_losses_parameters,
    252             ),)
--> 253         elif len(arrays) == 0:
    254             raise ValueError("PVSystem must have at least one Array. "
    255                              "If you want to create a PVSystem instance "

TypeError: object of type 'Array' has no len()

```

Not a bug per se, since the PVSystem docstring requests that `arrays` be iterable. Still, a bit inconvenient to have to do this

```
mount = pvlib.pvsystem.FixedMount(surface_tilt=35, surface_azimuth=180)
array = pvlib.pvsystem.Array(mount=mount)
pv = pvlib.pvsystem.PVSystem(arrays=[array])
```

**Describe the solution you'd like**
Handle `arrays=array` where `array` is an instance of `Array`

**Describe alternatives you've considered**
Status quo - either make the single Array into a list, or use the PVSystem kwargs.

