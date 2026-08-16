_golden_sect_DataFrame changes in 0.9.4
**Describe the bug**

`0.9.4` introduced the following changes in the `_golden_sect_DataFrame`: We are checking `upper` and `lower` parameters and raise an error if `lower > upper`.

https://github.com/pvlib/pvlib-python/blob/81598e4fa8a9bd8fadaa7544136579c44885b3d1/pvlib/tools.py#L344-L345

`_golden_sect_DataFrame` is used by `_lambertw`:

https://github.com/pvlib/pvlib-python/blob/81598e4fa8a9bd8fadaa7544136579c44885b3d1/pvlib/singlediode.py#L644-L649

I often have slightly negative `v_oc` values (really close to 0) when running simulations (second number in the array below):
```
array([ 9.46949758e-16, -8.43546518e-15,  2.61042547e-15,  3.82769773e-15,
        1.01292315e-15,  4.81308106e+01,  5.12484772e+01,  5.22675087e+01,
        5.20708941e+01,  5.16481028e+01,  5.12364071e+01,  5.09209060e+01,
        5.09076598e+01,  5.10187680e+01,  5.11328118e+01,  5.13997628e+01,
        5.15121386e+01,  5.05621451e+01,  4.80488068e+01,  7.18224446e-15,
        1.21386700e-14,  6.40136698e-16,  4.36081007e-16,  6.51236255e-15])
```

If we have one negative number in a large timeseries, the simulation will crash which seems too strict.

**Expected behavior**

That would be great to either:
* Have this data check be less strict and allow for slightly negative numbers, which are not going to affect the quality of the results.
* On `_lambertw`: Do not allow negative `v_oc` and set negative values to `np.nan`, so that the error is not triggered. It will be up to the upstream code (user) to manage those `np.nan`.

**Versions:**
 - ``pvlib.__version__``: >= 0.9.4
 - ``pandas.__version__``: 1.5.3
 - python: 3.10.11

singlediode error with very low effective_irradiance
**Describe the bug**

Since pvlib 0.9.4 release (https://github.com/pvlib/pvlib-python/pull/1606) I get an error while running the single-diode model with some very low effective irradiance values.

**To Reproduce**

```python
from pvlib import pvsystem

effective_irradiance=1.341083e-17
temp_cell=13.7 

cec_modules = pvsystem.retrieve_sam('CECMod')
cec_module = cec_modules['Trina_Solar_TSM_300DEG5C_07_II_']

mount = pvsystem.FixedMount()
array = pvsystem.Array(mount=mount,
                       module_parameters=cec_module)

system = pvsystem.PVSystem(arrays=[array])

params = system.calcparams_cec(effective_irradiance, 
                               temp_cell)

system.singlediode(*params)
```

```in _golden_sect_DataFrame(params, lower, upper, func, atol)
    303 """
    304 Vectorized golden section search for finding maximum of a function of a
    305 single variable.
   (...)
    342 pvlib.singlediode._pwr_optfcn
    343 """
    344 if np.any(upper - lower < 0.):
--> 345     raise ValueError('upper >= lower is required')
    347 phim1 = (np.sqrt(5) - 1) / 2
    349 df = params

ValueError: upper >= lower is required
```

**Expected behavior**
This complicates the bifacial modeling procedure as `run_model_from_effective_irradiance` can be called with very low irradiance values estimated by pvfactors (at sunrise or sunset for instance). 

**Versions:**
 - ``pvlib.__version__``:  0.9.4
 - ``pandas.__version__``: 1.5.3
 - python: 3.10

**Additional context**

v_oc is negative in this case which causes the error. 

```python
from pvlib.singlediode import _lambertw_v_from_i
photocurrent = params[0]
saturation_current = params[1]
resistance_series = params[2]
resistance_shunt = params[3]
nNsVth = params[4]
v_oc = _lambertw_v_from_i(resistance_shunt, resistance_series, nNsVth, 0.,
                              saturation_current, photocurrent)
```

