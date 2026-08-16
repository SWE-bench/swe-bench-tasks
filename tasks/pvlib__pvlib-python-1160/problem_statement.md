ValueError: SingleAxisTracker, Array, and running the model on a tuple/list of weather
**Describe the bug**
I know a refactoring of the Array with single axis tracking is in the works #1146. In the meantime, a `ValueError` is raised when trying to run a SingleAxisTracker defined with an array and supplying (ghi, dni, dhi) weather as a tuple/list. I would expect calling `run_model([weather])` would work similarly to a modelchain for a fixed system with an array singleton. The error stems from `pvlib.tracking.SingleAxisTracker.get_irradiance`  because most inputs are `pandas.Series`, but ghi, dhi, dni are `Tuple[Series]`.

**To Reproduce**
```python
import pandas as pd
from pvlib.location import Location
from pvlib.pvsystem import Array
from pvlib.tracking import SingleAxisTracker
from pvlib.modelchain import ModelChain


array_params = {
    "surface_tilt": None,
    "surface_azimuth": None,
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


tracking = SingleAxisTracker(
    arrays=[Array(**array_params, name=0)],
    axis_tilt=0,
    axis_azimuth=180,
    gcr=0.1,
    backtrack=True,
    inverter_parameters=inverter_parameters,
)

weather = pd.DataFrame(
    {
        "ghi": [1100.0, 1101.0],
        "dni": [1000.0, 1001],
        "dhi": [100.0, 100],
        "module_temperature": [25.0, 25],
    },
    index=pd.DatetimeIndex(
        [pd.Timestamp("2021-01-20T12:00-05:00"), pd.Timestamp("2021-01-20T12:05-05:00")]
    ),
)
mc = ModelChain(
    tracking,
    location,
    aoi_model="no_loss",
    spectral_model="no_loss",
)
mc.run_model(weather)  # OK
mc.run_model([weather])  # ValueError

```

**Versions:**
 - ``pvlib.__version__``: 0.9.0-alpha.2+2.g47654a0

