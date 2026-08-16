vtkVolume needs wrapping like vtkActor
We wrap vtkActor nicely and should do the same for vtkVolume to make lookup table modification during volume rendering nicer.

```py
import pyvista as pv
from pyvista import examples

vol = examples.download_knee_full()

p = pv.Plotter(notebook=0)
actor = p.add_volume(vol, cmap="bone", opacity="sigmoid")
actor.mapper.lookup_table.cmap = 'viridis'
p.show()
```

```
---------------------------------------------------------------------------
AttributeError                            Traceback (most recent call last)
Input In [3], in <cell line: 8>()
      6 p = pv.Plotter(notebook=0)
      7 actor = p.add_volume(vol, cmap="bone", opacity="sigmoid")
----> 8 actor.mapper.lookup_table.cmap = 'viridis'
      9 p.show()

AttributeError: 'vtkmodules.vtkRenderingCore.vtkVolume' object has no attribute 'mapper'
```
