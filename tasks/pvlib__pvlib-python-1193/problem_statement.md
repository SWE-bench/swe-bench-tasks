TypeError: running ModelChain with Arrays and module_temperature
**Describe the bug**
Another bug using Arrays. This time a TypeError is raised in `pvlib.modelchain._get_cell_temperature` because `self.system.temperature_model_parameters` is zipped with dataframe tuples but is never a tuple itself
https://github.com/pvlib/pvlib-python/blob/dc617d0c182bc8eec57898a039cb5115b425645f/pvlib/modelchain.py#L1525

**To Reproduce**
```python
import traceback
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
        "a": -3.47,
        "b": -0.0594,
        "deltaT": 3.0,
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
poa = pd.DataFrame(
    {
        "poa_global": [1100.0, 1101.0],
        "poa_direct": [1000.0, 1001.0],
        "poa_diffuse": [100.0, 100.0],
        "module_temperature": [35.0, 33.0],
    },
    index=pd.DatetimeIndex(
        [pd.Timestamp("2021-01-20T12:00-05:00"), pd.Timestamp("2021-01-20T12:05-05:00")]
    ),
)
standard = poa.copy().rename(
    columns={"poa_global": "ghi", "poa_direct": "dni", "poa_diffuse": "dhi"}
)
effective = poa.copy()[["module_temperature", "poa_global"]].rename(
    columns={"poa_global": "effective_irradiance"}
)
mc = ModelChain(
    array_sys,
    location,
    aoi_model="no_loss",
    spectral_model="no_loss",
)
try:
    mc.run_model([standard])
except TypeError:
    print(traceback.format_exc())
else:
    raise RuntimeError("expected a type error")
try:
    mc.run_model_from_poa([poa])
except TypeError:
    print(traceback.format_exc())
else:
    raise RuntimeError("expected a type error")
try:
    mc.run_model_from_effective_irradiance([effective])
except TypeError:
    print(traceback.format_exc())
else:
    raise RuntimeError("expected a type error")

```

**Versions:**
 - ``pvlib.__version__``:  master/g684b247

