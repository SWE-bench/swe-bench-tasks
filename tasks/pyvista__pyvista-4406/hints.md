First, these lines should reset the active_scalars to the last scalars added to the tetrahedral mesh:

https://github.com/pyvista/pyvista/blob/a87cf37d9cea6fc68d8099a56d86ded8f6e78734/pyvista/core/filters/rectilinear_grid.py#L119-L123

These subsequent lines pop out the active scalars, which is somehow the blank scalars, and set it as "vtkOriginalCellIds".

https://github.com/pyvista/pyvista/blob/a87cf37d9cea6fc68d8099a56d86ded8f6e78734/pyvista/core/filters/rectilinear_grid.py#L125-L129

Edit: I am wrong the first set of lines, would only set active scalars if there are none present, but the unnamed scalars are active.  We just need to reset the active scalars according to the original mesh I think.
Good point. Thanks @MatthewFlamm for pointing this out. We'll have this added in the v0.39.1 patch.