golden-section search fails when upper and lower bounds are equal
**Describe the bug**
I was using pvlib for sometime now and until now I was always passing a big dataframe containing readings of a long period. Because of some changes in our software architecture, I need to pass the weather readings as a single reading (a dataframe with only one row) and I noticed that for readings that GHI-DHI are zero pvlib fails to calculate the output and returns below error while the same code executes correctly with weather information that has non-zero GHI-DHI:
```python
import os
import pathlib
import time
import json
from datetime import datetime
from time import mktime, gmtime

import pandas as pd

from pvlib import pvsystem
from pvlib import location as pvlocation
from pvlib import modelchain
from pvlib.temperature import TEMPERATURE_MODEL_PARAMETERS as PARAMS # not used -- to remove
from pvlib.bifacial.pvfactors import pvfactors_timeseries
from pvlib.temperature import TEMPERATURE_MODEL_PARAMETERS

class PV:
    def pv_transform_time(self, val):
        # tt = gmtime(val / 1000)
        tt = gmtime(val)
        dd = datetime.fromtimestamp(mktime(tt))
        timestamp = pd.Timestamp(dd)
        return timestamp

    def __init__(self, model: str, inverter: str, latitude: float, longitude: float, **kwargs):
        # super().__init__(**kwargs)

        temperature_model_parameters = TEMPERATURE_MODEL_PARAMETERS["sapm"][
            "open_rack_glass_glass"
        ]
        # Load the database of CEC module model parameters
        modules = pvsystem.retrieve_sam("cecmod")
        # Load the database of CEC inverter model parameters
        inverters = pvsystem.retrieve_sam("cecinverter")


        # A bare bone PV simulator

        # Load the database of CEC module model parameters
        modules = pvsystem.retrieve_sam('cecmod')
        inverters = pvsystem.retrieve_sam('cecinverter')
        module_parameters = modules[model]
        inverter_parameters = inverters[inverter]

        location = pvlocation.Location(latitude=latitude, longitude=longitude)
        system = pvsystem.PVSystem(module_parameters=module_parameters, inverter_parameters=inverter_parameters, temperature_model_parameters=temperature_model_parameters)
        self.modelchain = modelchain.ModelChain(system, location, aoi_model='no_loss', spectral_model="no_loss")

    def process(self, data):
        weather = pd.read_json(data)
        # print(f"raw_weather: {weather}")
        weather.drop('time.1', axis=1, inplace=True)
        weather['time'] = pd.to_datetime(weather['time']).map(datetime.timestamp) # --> this works for the new process_weather code and also the old weather file
        weather["time"] = weather["time"].apply(self.pv_transform_time)
        weather.index = weather["time"]
        # print(f"weather: {weather}")
        # print(weather.dtypes)
        # print(weather['ghi'][0])
        # print(type(weather['ghi'][0]))

        # simulate
        self.modelchain.run_model(weather)
        # print(self.modelchain.results.ac.to_frame().to_json())
        print(self.modelchain.results.ac)


# good data
good_data = "{\"time\":{\"12\":\"2010-01-01 13:30:00+00:00\"},\"ghi\":{\"12\":36},\"dhi\":{\"12\":36},\"dni\":{\"12\":0},\"Tamb\":{\"12\":8.0},\"WindVel\":{\"12\":5.0},\"WindDir\":{\"12\":270},\"time.1\":{\"12\":\"2010-01-01 13:30:00+00:00\"}}"

# data that causes error
data = "{\"time\":{\"4\":\"2010-01-01 05:30:00+00:00\"},\"ghi\":{\"4\":0},\"dhi\":{\"4\":0},\"dni\":{\"4\":0},\"Tamb\":{\"4\":8.0},\"WindVel\":{\"4\":4.0},\"WindDir\":{\"4\":240},\"time.1\":{\"4\":\"2010-01-01 05:30:00+00:00\"}}"
p1 = PV(model="Trina_Solar_TSM_300DEG5C_07_II_", inverter="ABB__MICRO_0_25_I_OUTD_US_208__208V_", latitude=51.204483, longitude=5.265472)
p1.process(good_data)
print("=====")
p1.process(data)
```
Error:
```log
$ python3 ./tmp-pv.py 
time
2010-01-01 13:30:00    7.825527
dtype: float64
=====
/home/user/.local/lib/python3.10/site-packages/pvlib/tools.py:340: RuntimeWarning: divide by zero encountered in divide
  np.trunc(np.log(atol / (df['VH'] - df['VL'])) / np.log(phim1)))
Traceback (most recent call last):
  File "/home/user/workspace/enorch/simulator/simulator_processor/src/pv/./tmp-pv.py", line 88, in <module>
    p1.process(data)
  File "/home/user/workspace/enorch/simulator/simulator_processor/src/pv/./tmp-pv.py", line 75, in process
    self.modelchain.run_model(weather)
  File "/home/user/.local/lib/python3.10/site-packages/pvlib/modelchain.py", line 1770, in run_model
    self._run_from_effective_irrad(weather)
  File "/home/user/.local/lib/python3.10/site-packages/pvlib/modelchain.py", line 1858, in _run_from_effective_irrad
    self.dc_model()
  File "/home/user/.local/lib/python3.10/site-packages/pvlib/modelchain.py", line 790, in cec
    return self._singlediode(self.system.calcparams_cec)
  File "/home/user/.local/lib/python3.10/site-packages/pvlib/modelchain.py", line 772, in _singlediode
    self.results.dc = tuple(itertools.starmap(
  File "/home/user/.local/lib/python3.10/site-packages/pvlib/pvsystem.py", line 931, in singlediode
    return singlediode(photocurrent, saturation_current,
  File "/home/user/.local/lib/python3.10/site-packages/pvlib/pvsystem.py", line 2826, in singlediode
    out = _singlediode._lambertw(
  File "/home/user/.local/lib/python3.10/site-packages/pvlib/singlediode.py", line 651, in _lambertw
    p_mp, v_mp = _golden_sect_DataFrame(params, 0., v_oc * 1.14,
  File "/home/user/.local/lib/python3.10/site-packages/pvlib/tools.py", line 364, in _golden_sect_DataFrame
    raise Exception("Iterations exceeded maximum. Check that func",
Exception: ('Iterations exceeded maximum. Check that func', ' is not NaN in (lower, upper)')
```

I have to mention that for now the workaround that I am using is to pass the weather data as a dataframe with two rows, the first row is a good weather data that pvlib can process and the second row is the incoming weather reading (I can also post that code if you want).

**Expected behavior**
PVlib should have consistent behavior and regardless of GHI-DHI readings.

**Versions:**
```python
>>> import pvlib
>>> import pandas
>>> pvlib.__version__
'0.9.1'
>>> pandas.__version__
'1.4.3'
``` 
 - python: 3.10.6
- OS: Ubuntu 22.04.1 LTS
