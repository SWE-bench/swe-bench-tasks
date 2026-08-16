``Multiblock``.plot does not work when using ``PointSet``
### Describe the bug, what's wrong, and what you expected.

It seems ``MultiBlock`` entities made of ``PointSet`` plot nothing when using ``plot`` method.

### Steps to reproduce the bug.

```python
import pyvista as pv
import numpy as np

points_arr = np.array(
    [
        [0.0, 1.0, 0.0],
        [0.0, 0.0, 0.0],
        [1.0, 1.0, 0.0],
        [1.0, 0.0, 0.0],
        [0.0, 0.0, 1.0],
        [1.0, 0.0, 1.0],
        [1.0, 1.0, 1.0],
        [0.0, 1.0, 1.0],
    ]
)

points = pv.MultiBlock()
for each_kp in points_arr:
    points.append(pv.PointSet(each_kp))

points.plot()
```

### System Information

```shell
--------------------------------------------------------------------------------
  Date: Wed May 10 18:07:18 2023 CEST

                OS : Darwin
            CPU(s) : 8
           Machine : arm64
      Architecture : 64bit
               RAM : 16.0 GiB
       Environment : IPython
       File system : apfs
        GPU Vendor : Apple
      GPU Renderer : Apple M2
       GPU Version : 4.1 Metal - 83.1
  MathText Support : False

  Python 3.11.1 (main, Dec 23 2022, 09:28:24) [Clang 14.0.0
  (clang-1400.0.29.202)]

           pyvista : 0.39.0
               vtk : 9.2.6
             numpy : 1.24.3
        matplotlib : 3.7.1
            scooby : 0.7.1
             pooch : v1.7.0
           imageio : 2.28.0
           IPython : 8.12.1
        ipywidgets : 8.0.6
             scipy : 1.10.1
              tqdm : 4.65.0
        jupyterlab : 3.6.3
         pythreejs : 2.4.2
      nest_asyncio : 1.5.6
--------------------------------------------------------------------------------
```


### Screenshots

<img width="624" alt="image" src="https://github.com/pyvista/pyvista/assets/28149841/a1b0999f-2d35-4911-a216-eb6503955860">

