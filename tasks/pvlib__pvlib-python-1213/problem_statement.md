Bug within scaling.py wavelet calculation methodology
**Describe the bug**
Mathematical error within the wavelet computation for the scaling.py WVM implementation. Error arises from the methodology, as opposed to just a software bug. 

**To Reproduce**
Steps to reproduce the behavior:
```
import numpy as np
from pvlib import scaling
cs = np.random.rand(2**14)
w, ts = scaling._compute_wavelet(cs,1)
print(np.all( (sum(w)-cs) < 1e-8 ))  # Returns False, expect True
```

**Expected behavior**
For a discrete wavelet transform (DWT) the sum of all wavelet modes should equate to the original data. 

**Versions:**
 - ``pvlib.__version__``: 0.7.2
 - ``pandas.__version__``: 1.2.3
 - python: 3.8.8

**Additional context**
This bug is also present in the [PV_LIB](https://pvpmc.sandia.gov/applications/wavelet-variability-model/) Matlab version that was used as the basis for this code (I did reach out to them using the PVLIB MATLAB email form, but don't know who actually wrote that code). Essentially, the existing code throws away the highest level of Detail Coefficient in the transform and keeps an extra level of Approximation coefficient. The impact on the calculation is small, but leads to an incorrect DWT and reconstruction. I have a fix that makes the code pass the theoretical test about the DWT proposed under 'To Reproduce' but there may be some question as to whether this should be corrected or left alone to match the MATLAB code it was based on. 

