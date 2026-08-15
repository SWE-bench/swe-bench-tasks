I'm not sure why codecov/patch failed on this commit 
 > I'm not sure why codecov/patch failed on this commit

The build which using pandas is failing on Azure. You should check if there is a change of behaviour with the new code (maybe we need to change the error message). The codecov failure is due to the Azure failure.
We originally did not support `pd.SparseArray` because of: https://github.com/scikit-learn/scikit-learn/issues/7352#issuecomment-305472045 But it looks like its been fixed in pandas: https://github.com/pandas-dev/pandas/pull/22325 and the original issue with `pd.SparseSeries` is gone.

```py
import pandas as pd
import numpy as np

pd.__version__
# 0.24.2

ss1 = pd.Series(pd.SparseArray([1, 0, 2, 1, 0]))
ss2 = pd.SparseSeries([1, 0, 2, 1, 0])

np.asarray(ss1)
# array([1, 0, 2, 1, 0])

np.asarray(ss2)
# array([1, 0, 2, 1, 0])
```

This was fixed in pandas version `0.24`.
Ok, I’ll close this PR
Cron is still failing on master. I think this should be re-opened if only to ignore the future warning in `test_type_of_target`.
We can support pandas sparse arrays as of pandas 0.24. This means `type_of_target` does not need to error for pandas > 0.24 on sparse arrays. But technically we still need to raise for pandas <= 0.23. One way to do this is to check pandas version and raise accordingly.
@thomasjpfan be careful with the example, because the default fill value in pandas is np.nan and not 0 (for better or worse ...). So the correct example would be with nans (or by specifying 0 as the fill value):

with pandas 0.22
```
a = pd.SparseArray([1, np.nan, 2, 1, np.nan])

np.array(a)
# array([1., 2., 1.])

np.array(pd.SparseSeries(a))
# array([1., 2., 1.])

np.array(pd.Series(a))
# array([ 1., nan,  2.,  1., nan])
```

with pandas 0.24
```
np.array(a)                    
# array([ 1., nan,  2.,  1., nan])

np.array(pd.SparseSeries(a))                      
# array([ 1., nan,  2.,  1., nan])

np.array(pd.Series(a))         
# array([ 1., nan,  2.,  1., nan])
```

(so apparently even before 0.24, a Series (not SparseSeries) had the correct behaviour)
I suppose the original check for SparseSeries was there to have a more informative error message (as I can imagine that if the y labels at once became a different length, that might have been confusing). If that is the case, I would indeed keep the check as is but only do it for pandas <= 0.23, as @thomasjpfan suggests. 