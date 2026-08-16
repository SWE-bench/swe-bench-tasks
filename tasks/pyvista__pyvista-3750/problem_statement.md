Unexpected threshold behavior
### Describe the bug, what's wrong, and what you expected.

I'm using simple structed grids of cells, and need to filter-out some "nodata" cells. To do this, I'm setting scalar values to the cell data, then using [threshold](https://docs.pyvista.org/api/core/_autosummary/pyvista.DataSetFilters.threshold.html) with the nodata value with `invert=True`. However, I'm getting confusing and inconsistent results compared to ParaView.

### Steps to reproduce the bug.

```python
import numpy as np
import pyvista

x = np.arange(5, dtype=float)
y = np.arange(6, dtype=float)
z = np.arange(2, dtype=float)
xx, yy, zz = np.meshgrid(x, y, z)
mesh = pyvista.StructuredGrid(xx, yy, zz)
mesh.cell_data.set_scalars(np.repeat(range(5), 4))

# All data
mesh.plot(show_edges=True)
# output is normal

# Filtering out nodata (zero) values
mesh.threshold(0, invert=True).plot(show_edges=True)
# output does not look normal, only 0-value cells are shown
```

### System Information

```shell
--------------------------------------------------------------------------------
  Date: Thu Nov 17 15:23:57 2022 New Zealand Daylight Time

                OS : Windows
            CPU(s) : 12
           Machine : AMD64
      Architecture : 64bit
               RAM : 31.7 GiB
       Environment : IPython
        GPU Vendor : NVIDIA Corporation
      GPU Renderer : NVIDIA RTX A4000/PCIe/SSE2
       GPU Version : 4.5.0 NVIDIA 472.39

  Python 3.9.13 | packaged by conda-forge | (main, May 27 2022, 16:50:36) [MSC
  v.1929 64 bit (AMD64)]

           pyvista : 0.37.0
               vtk : 9.1.0
             numpy : 1.22.3
           imageio : 2.22.0
            scooby : 0.7.0
             pooch : v1.6.0
        matplotlib : 3.6.2
             PyQt5 : 5.12.3
           IPython : 8.6.0
          colorcet : 3.0.1
             scipy : 1.8.0
              tqdm : 4.63.0
            meshio : 5.3.4
--------------------------------------------------------------------------------
```


### Screenshots

Normal looking whole grid:
![image](https://user-images.githubusercontent.com/895458/202339692-5046b23f-c3c8-4b2c-aaa7-4aa06afbae9f.png)

Odd-looking threshold attempt with pyvista, showing only 0-values:
![image](https://user-images.githubusercontent.com/895458/202339879-b2270e4c-a71b-4d43-86f8-4f67445b7b69.png)

Expected result with ParaView theshold filter with upper/lower set to 0 and invert selected:
![image](https://user-images.githubusercontent.com/895458/202340379-fea26838-b0f4-4828-b510-825f53522e87.png)

Apologies for any "user error", as I'm new to this package.
