Confusing behaviour of ParametricEllipsoid
### Describe the bug, what's wrong, and what you expected.

When creating a ParametricEllispoid using a direction of [0, 1, 0], the ellipsoid is rotated along the y axis.  
For example if setting the direction to [1e-5, 1, 0], which corresponds to approximately similar direction, the ellipsoid displays then the correct behaviour.

### Steps to reproduce the bug.

```python
import pyvista as pv

ellipsoid = pv.ParametricEllipsoid(300, 100, 10, direction=[0, 1, 0])
```

### System Information

```shell
Date: Wed Sep 06 14:07:38 2023 CEST

                OS : Linux
            CPU(s) : 8
           Machine : x86_64
      Architecture : 64bit
               RAM : 31.2 GiB
       Environment : Jupyter
       File system : ext4
        GPU Vendor : Intel
      GPU Renderer : Mesa Intel(R) UHD Graphics (CML GT2)
       GPU Version : 4.6 (Core Profile) Mesa 22.0.1
  MathText Support : False

  Python 3.8.13 (default, Apr 19 2022, 02:32:06)  [GCC 11.2.0]

           pyvista : 0.41.1
               vtk : 9.2.6
             numpy : 1.24.4
        matplotlib : 3.3.4
            scooby : 0.7.2
             pooch : v1.7.0
           imageio : 2.31.1
           IPython : 8.12.2
        ipywidgets : 8.0.7
             scipy : 1.10.1
              tqdm : 4.65.0
        jupyterlab : 3.6.5
             trame : 2.5.2
      trame_client : 2.10.0
      trame_server : 2.11.7
         trame_vtk : 2.5.8
      nest_asyncio : 1.5.6
```


### Screenshots

Here is the given ellipsoid
![confusing_ellipsoid](https://github.com/pyvista/pyvista/assets/57682091/f0e1b5f7-eca1-4224-a020-df44385ed68b)
Here is what is expected
![expected_ellipsoid](https://github.com/pyvista/pyvista/assets/57682091/d4f67ead-9928-4af3-9c3a-b6121180b780)

