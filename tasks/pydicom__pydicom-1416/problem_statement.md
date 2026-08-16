Segmented LUTs are incorrectly expanded
**Describe the bug**
`pydicom.pixel_data_handlers.util._expand_segmented_lut()` expands segmented LUTs to an incorrect length.

**Expected behavior**
A correct length LUT to be produced.

**Steps To Reproduce**
Initialize the following variables.
```
import numpy as np
length = 48
y0 = 163
y1 = 255
```

Run the following two lines from [`pydicom.pixel_data_handlers.util._expand_segmented_lut()`](https://github.com/pydicom/pydicom/blob/699c9f0a8e190d463dd828822106250523d38154/pydicom/pixel_data_handlers/util.py#L875
)
```
step = (y1 - y0) / length
vals = np.around(np.arange(y0 + step, y1 + step, step))
```

Confirm that variable `vals` if of incorrect length
```
print(len(vals) == length)
> False
```

Alternatively, the code below produces similarly false results

```
from pydicom.pixel_data_handlers.util import _expand_segmented_lut 
lut = _expand_segmented_lut(([0, 1, 163, 1, 48, 255]), "B")
print(len(lut) == (1+48))
> False
```

`np.arange` [explicitly states](https://numpy.org/doc/stable/reference/generated/numpy.arange.html) that it's "results will often not be consistent" when using "non-integer step", which is a very possible scenario in this function. The following alternative code does function correctly:

```
vals = np.around(np.linspace(y0 + step, y1, length))
```

**Your environment**
```bash
$ python -m pydicom.env_info
module       | version
------       | -------
platform     | Darwin-20.5.0-x86_64-i386-64bit
Python       | 3.7.10 (default, Feb 26 2021, 10:16:00)  [Clang 10.0.0 ]
pydicom      | 2.1.2
gdcm         | _module not found_
jpeg_ls      | _module not found_
numpy        | 1.20.3
PIL          | 8.2.0
```
