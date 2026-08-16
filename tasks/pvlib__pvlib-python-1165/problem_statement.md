ValueError: ModelChain.run_from_effective_irradiance([weather]) when only providing temp_air and wind_speed
**Describe the bug**
According to the (new) docstring for `ModelChain.run_from_effective_irradiance`, cell temperature can be calculated from temperature_model using `'effective_irradiance'`. This is not the case when using one or more arrays 
https://github.com/pvlib/pvlib-python/blame/master/pvlib/modelchain.py#L1589-L1606

**To Reproduce**
```python
from copy import deepcopy
import pandas as pd
from pvlib.location import Location
from pvlib.pvsystem import Array, PVSystem
from pvlib.modelchain import ModelChain


array_params = {
    "surface_tilt": 32.0,
    "surface_azimuth": 180.0,
    "module": "Canadian_Solar_Inc__CS5P_220M",
    "albedo": 0.2,
    "temperature_model_parameters": {
        "u_c": 29.0,
        "u_v": 0.0,
        "eta_m": 0.1,
        "alpha_absorption": 0.9,
    },
    "strings": 5,
    "modules_per_string": 7,
    "module_parameters": {
        "alpha_sc": 0.004539,
        "gamma_ref": 1.2,
        "mu_gamma": -0.003,
        "I_L_ref": 5.11426,
        "I_o_ref": 8.10251e-10,
        "R_sh_ref": 381.254,
        "R_sh_0": 400.0,
        "R_s": 1.06602,
        "cells_in_series": 96,
        "R_sh_exp": 5.5,
        "EgRef": 1.121,
    },
}
inverter_parameters = {
    "Paco": 250.0,
    "Pdco": 259.589,
    "Vdco": 40.0,
    "Pso": 2.08961,
    "C0": -4.1e-05,
    "C1": -9.1e-05,
    "C2": 0.000494,
    "C3": -0.013171,
    "Pnt": 0.075,
}


location = Location(latitude=33.98, longitude=-115.323, altitude=2300)

array_sys = PVSystem(
    arrays=[
        Array(**array_params, name=0),
    ],
    inverter_parameters=inverter_parameters,
)
weather = pd.DataFrame(
    {
        "effective_irradiance": [1100.0, 1101.0],
        "temp_air": [25.0, 26.0],
        "wind_speed": [10.0, 10.0],
    },
    index=pd.DatetimeIndex(
        [pd.Timestamp("2021-01-20T12:00-05:00"), pd.Timestamp("2021-01-20T12:05-05:00")]
    ),
)
mc0 = ModelChain(
    array_sys,
    location,
    aoi_model="no_loss",
    spectral_model="no_loss",
)
mc1 = deepcopy(mc0)

mc0.run_model_from_effective_irradiance(weather)
assert isinstance(mc0.results.cell_temperature, pd.Series)


mc1.run_model_from_effective_irradiance([weather])  # ValueError

```

**Expected behavior**
Running the model with both `weather` and `[weather]` work


**Versions:**
 - ``pvlib.__version__``: 0.9.0-alpha.2+5.gb40df75
