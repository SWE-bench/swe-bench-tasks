Minimal script to reproduce:
```
import pandas as pd
from sklearn.utils.validation import check_array
check_array(pd.Series([1, 2, 3]), ensure_2d=False, warn_on_dtype=True)
```
Related PR #10949 
Thanks for reporting. Yeah would be good to get this into 0.20.1, hrm...
Heading to bed, seems that an easy solution will be:
change
```
if hasattr(array, "dtypes") and hasattr(array, "__array__"):
        dtypes_orig = np.array(array.dtypes)
```
to something like
```
if hasattr(array, "dtypes") and hasattr(array, "__array__") and hasattr(array.dtypes, "__array__"):
        dtypes_orig = np.array(array.dtypes)
```