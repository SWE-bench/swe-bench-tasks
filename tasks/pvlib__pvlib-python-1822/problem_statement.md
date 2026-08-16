singlediode: newton solver fails with Series input of length one
The vectorized newton solver doesn't work if parameters are Series of length one.

```

import pandas as pd
import pvlib


args = (0.001, 1.5, 6., 5e-9, 1000., 0.5)
params = pvlib.pvsystem.calcparams_desoto(1000., 25, *args)
params_series = pvlib.pvsystem.calcparams_desoto(pd.Series(data=[1000.]),
                                                 pd.Series([25.]), *args)
params_series2 = pvlib.pvsystem.calcparams_desoto(pd.Series(data=[1000., 1000.]),
                                                  pd.Series([25., 25.]), *args)
# works with each input as float
result = pvlib.pvsystem.singlediode(*params, method='newton')

# works with Series if length > 1
result_series2 = pvlib.pvsystem.singlediode(*params_series2, method='newton')

# errors with Series if length is 1
result_series = pvlib.pvsystem.singlediode(*params_series, method='newton')
```

**Versions:**
 - ``pvlib.__version__``: 0.9.5

