Rectilinear grid does not allow Sequences as inputs
### Describe the bug, what's wrong, and what you expected.

Rectilinear grid gives an error when `Sequence`s are passed in, but `ndarray` are ok.

### Steps to reproduce the bug.

This doesn't work
```python
import pyvista as pv
pv.RectilinearGrid([0, 1], [0, 1], [0, 1])
```

This works
```py
import pyvista as pv
import numpy as np
pv.RectilinearGrid(np.ndarray([0, 1]), np.ndarray([0, 1]), np.ndarray([0, 1]))
```
### System Information

```shell
--------------------------------------------------------------------------------
  Date: Wed Apr 19 20:15:10 2023 UTC

                OS : Linux
            CPU(s) : 2
           Machine : x86_64
      Architecture : 64bit
       Environment : IPython
        GPU Vendor : Mesa/X.org
      GPU Renderer : llvmpipe (LLVM 11.0.1, 256 bits)
       GPU Version : 4.5 (Core Profile) Mesa 20.3.5

  Python 3.11.2 (main, Mar 23 2023, 17:12:29) [GCC 10.2.1 20210110]

           pyvista : 0.38.5
               vtk : 9.2.6
             numpy : 1.24.2
           imageio : 2.27.0
            scooby : 0.7.1
             pooch : v1.7.0
        matplotlib : 3.7.1
           IPython : 8.12.0
--------------------------------------------------------------------------------
```


### Screenshots

_No response_
