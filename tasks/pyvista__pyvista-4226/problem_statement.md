Diffuse and Specular setters silently ignore invalid values
### Describe the bug, what's wrong, and what you expected.

While working on #3870, I noticed that `diffuse` and `specular` do not always get set on `pyvista.Property`. This happens if an invalid value is used. For example, diffuse should be between 0-1, but if you pass a value of 2.0, `vtkProperty` corrects it to 1.0:

```py
>>> import vtk
>>> prop = vtk.vtkProperty()
>>> prop.SetDiffuse(2.0)
>>> prop.GetDiffuse()
1.0
```

This similarly happens for specular, which should also have a valid range of 0-1.

Should we have `pyvista.Property`'s setters for these methods error out when an invalid value is passed? I ask because I definitely wasted time trying to figure out why a diffuse value of 1.0 looks the same as 2.0 before thinking it should be between 0 and 1.

Perhaps this at a minimum should be documented in the setters and docstring for `add_mesh()`?

### Steps to reproduce the bug.

```python
import pyvista as pv

pl = pv.Plotter()
a = pl.add_mesh(pv.Sphere(), diffuse=3.0, specular=10)
# Expected to error for invalid values
```

### System Information

```shell
main branch
```


### Screenshots

_No response_
