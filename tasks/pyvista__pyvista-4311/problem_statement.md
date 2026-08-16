Allow passing through cell data in `to_tetrahedra` method in RectilinearGrid
### Describe the feature you would like to be added.

No cell data is passed through when converting to a tetrahedra.  The user can currently request to pass through the original cell id, but it requires one more step to regenerate the cell data on the tetrahedralized mesh.

### Links to VTK Documentation, Examples, or Class Definitions.

_No response_

### Pseudocode or Screenshots

Currently we have to do

```python
mesh # Rectilinear or UniformGrid, which has cell data "cell_data"
tetra_mesh = mesh.to_tetrahedra(pass_cell_ids=True)
tetra_mesh["cell_data"] = mesh["cell_data"][tetra_mesh.cell_data.active_scalars]
```

It would be better to do something like

```python
mesh # Rectilinear or UniformGrid, which has cell data "cell_data"
tetra_mesh = mesh.to_tetrahedra(pass_cell_data=True)  # the prior code would occur inside the method
```
