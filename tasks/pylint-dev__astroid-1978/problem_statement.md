Deprecation warnings from numpy
### Steps to reproduce

1. Run pylint over the following test case:

```
"""Test case"""

import numpy as np
value = np.random.seed(1234)
```

### Current behavior
```
/home/bje/source/nemo/myenv/lib/python3.10/site-packages/astroid/raw_building.py:470: FutureWarning: In the future `np.long` will be defined as the corresponding NumPy scalar.  (This may have returned Python scalars in past versions.
  getattr(sys.modules[modname], name)
/home/bje/source/nemo/myenv/lib/python3.10/site-packages/astroid/raw_building.py:470: FutureWarning: In the future `np.long` will be defined as the corresponding NumPy scalar.  (This may have returned Python scalars in past versions.
  getattr(sys.modules[modname], name)
```

### Expected behavior
There should be no future warnings.

### python -c "from astroid import __pkginfo__; print(__pkginfo__.version)" output
2.12.13
