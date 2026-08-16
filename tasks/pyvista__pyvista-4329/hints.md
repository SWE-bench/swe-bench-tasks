Considering we are purely using VTK for this interface through the `vtk_to_numpy` function, I'm inclined to think this may be an upstream bug where the array doesn't interface completely

https://github.com/pyvista/pyvista/blob/eaa71a640264765c8a9b40d485b6ccdb970c87b0/pyvista/core/pointset.py#L762 

or perhaps there is a better way to access the Polys from the VTK object?
A pure VTK demonstration of the issue:

```py
import vtk
from vtkmodules.util.numpy_support import vtk_to_numpy

# https://github.com/pyvista/pyvista/issues/2705
sphere = vtk.vtkSphereSource()
sphere.Update()
mesh = sphere.GetOutput()


f = vtk_to_numpy(mesh.GetPolys().GetData())

>>> f
array([  3,   2,  30, ..., 840,  29,  28])
>>> a = f[1:4]
>>> a
array([ 2, 30,  0])
>>> b = f[5:8]
>>> b
array([30, 58,  0])
>>> f[1:4] = b
>>> f[5:8] = a
>>> f
array([  3,  30,  58, ..., 840,  29,  28])

assert all(f[1:4] == b) and all(f[5:8] == a), 'if this fails, we have more serious problems'

# access overwrites `f` in place which is unexpected and causes the check above to now fail
vtk_to_numpy(mesh.GetPolys().GetData())
assert all(f[1:4] == b) and all(f[5:8] == a), 'well, this is not expected'
```
Well, this was a joy to track down. The short answer: Use `vtkCellArray.GetConnectivityArray()` instead of `vtkCellArray.GetData()`.

The long explanation: A while ago, `vtkCellArray` was changed so that it can store either 32 bit or 64 bit connectivity data. This enabled saving memory when VTK is compiled with 64 bit ids (`vtkIdType`) AND if the mesh has less than 2 billion connectivity entries. This meant that `vtkCellArray` can store either a 32 bit or 64 bit array for connectivity. However, `GetData()` returns a `vtkIdTypeArray` which is usually compiled to be 64 bit so `vtkCellArray` could no longer return its internal array in this method. So, the placeholder implementation now makes a copy from its internal array to return. So changing this array does not actually affect the connectivity. The issue shown here is a side effect of this implementation. `vtkCellArray.GetConnectivityArray()` actually returns the internal array and can be safely changed to affect the connectivity. pyvista and VTK Python classes have to be changed to use `vtkCellArray.GetConnectivityArray()` and `vtkCellArray.GetOffsetsArray()`. Also don't use `vtkCellArray.SetCells()`. Use `vtkCellArray.SetData()` instead.
Unfortunately for PyVista, this is not an easy fix as `GetConnectivityArray()` is not a direct stand-in for `GetData()`. 

`GetData()` array has connectivity offsets (`GetOffsetsArray()`) embedded in the array, whereas `GetConnectivityArray()` does not. This is quite nice for `vtkPolyData.GetPolys()` if and only if all of the polys are the same size (e.g., 3 for triangulated mesh), but if there are mixed polys, this is pretty tough to work with when trying to update the array in-place:

```py
import numpy as np
import pyvista as pv
from pyvista import _vtk

vertices = np.array([[0, 0, 0], [1, 0, 0], [1, 1, 0], [0, 1, 0], [0.5, 0.5, -1]])

# mesh faces
faces = np.hstack(
    [
        [4, 0, 1, 2, 3],  # square
        [3, 0, 1, 4],  # triangle
        [3, 1, 2, 4],  # triangle
    ]
)

surf = pv.PolyData(vertices, faces)
```

```py
>>> _vtk.vtk_to_numpy(surf.GetPolys().GetData())
array([4, 0, 1, 2, 3, 3, 0, 1, 4, 3, 1, 2, 4])
```

```py
>>> _vtk.vtk_to_numpy(surf.GetPolys().GetConnectivityArray())
array([0, 1, 2, 3, 0, 1, 4, 1, 2, 4])
```

```py
>>> _vtk.vtk_to_numpy(surf.GetPolys().GetOffsetsArray())
array([ 0,  4,  7, 10])
```

In PyVista, we designed the `.cells`, `.faces`, `.strips`, `.lines`, etc. APIs around the assumption of having the connectivity offsets embedded in the array. This means we'd have to redesign these accessors entirely (breaking a lot of downstream code) just to enable this in-place operation. Further, changing the API to require users to deal with both connectivities and offsets as separate arrays will likely be too much of a burden.

------

> the placeholder implementation now makes a copy from its internal array to return. So changing this array does not actually affect the connectivity.

@berkgeveci, I'm curious if you think this copy could/will be fixed upstream in VTK so that `GetData()` could work with in-place operations?
Ah I see. Unfortunately, what you want is not possible. The underlying structure for `vtkCellArray` changed and it does not store the number of vertices per cell anymore. This is the main reason why `GetData()` creates a new array (something that I forgot). For backwards compatibility. But it has the side effect of this array being "detached" from the actual topology of the mesh. There are good reasons for this change:

- Most other codes and OpenGL prefer the new structure so there is more likelihood that VTK will be binary compatible with them.
- When we get rid of the vertex count and always have the offsets, we can have random access at no additional memory cost. In the past, for polydata, the offsets were built when needed to save memory.

Note that there is no loss of information here. You can simply recover the number of vertices of a cell by doing `offset[cellId+1]-offset[cellId]`. To make this work, the offsets array actually is of size `ncells+1` so that you can get the number of vertices for the last cell.

I understand that this will be a backwards incompatible change for PyVista but there is no other way. You can still support

```
# mesh faces
faces = np.hstack(
    [
        [4, 0, 1, 2, 3],  # square
        [3, 0, 1, 4],  # triangle
        [3, 1, 2, 4],  # triangle
    ]
)

surf = pv.PolyData(vertices, faces)
```

but it will have to create the connectivity and offsets array under the covers (or let VTK do it). But if you want to avoid the deep copy, you have to support `pv.PolyData(vertices, offsets, connectivity)`, which has to create a `vtkCellArray` and call `SetData()` on it.
I suggest avoiding the use of `GetData()` all together.

Also note that there is a bug in how `SetData()` works currently and when called from Python, it does not cause `vtkCellArray()` to hold a reference to the underlying numpy buffer. Unless you are keeping a reference to that object from the Python side, the VTK object will hold a reference to a junk pointer once the numpy array goes out of scope. I am working on a fix for this issue.
