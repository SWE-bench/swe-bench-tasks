This is a confirmed bug on the main. I tried a smaller example to reproduce the same

```python
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

rng = np.random.default_rng(0)
verts = rng.random(size=(10, 3))
mesh = Poly3DCollection([verts], label="surface")

fig, ax = plt.subplots(subplot_kw={"projection": "3d"})
mesh.set_edgecolor('k')
ax.add_collection3d(mesh)
ax.legend()
plt.show()
```
@sghelichkhani would you want to raise a PR for the issue? Your solution seems to be working for me!