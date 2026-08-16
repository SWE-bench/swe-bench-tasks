to_tetrahedra active scalars
### Describe the bug, what's wrong, and what you expected.

#4311 passes cell data through the `to_tetrahedra` call. However, after these changes.  The active scalars information is lost.

cc @akaszynski who implemented these changes in that PR.

### Steps to reproduce the bug.

```py
import pyvista as pv
import numpy as np
mesh = pv.UniformGrid(dimensions=(10, 10, 10))
mesh["a"] = np.zeros(mesh.n_cells)
mesh["b"] = np.ones(mesh.n_cells)
print(mesh.cell_data)
tet = mesh.to_tetrahedra()
print(tet.cell_data)
```

```txt
pyvista DataSetAttributes
Association     : CELL
Active Scalars  : a
Active Vectors  : None
Active Texture  : None
Active Normals  : None
Contains arrays :
    a                       float64    (729,)               SCALARS
    b                       float64    (729,)
pyvista DataSetAttributes
Association     : CELL
Active Scalars  : None
Active Vectors  : None
Active Texture  : None
Active Normals  : None
Contains arrays :
    a                       float64    (3645,)
    b                       float64    (3645,)
    vtkOriginalCellIds      int32      (3645,)
```

### System Information

```shell
Python 3.11.2 (main, Mar 23 2023, 17:12:29) [GCC 10.2.1 20210110]

           pyvista : 0.39.0
               vtk : 9.2.6
             numpy : 1.24.2
        matplotlib : 3.7.1
            scooby : 0.7.1
             pooch : v1.7.0
           imageio : 2.27.0
           IPython : 8.12.0
--------------------------------------------------------------------------------
```


### Screenshots

_No response_
