Cell wise and dimension reducing filters do not work for PointSet
### Describe the bug, what's wrong, and what you expected.

`PointSet` is an odd data type as it has no cells and simply represents a 0-dimensional geometry: point clouds.

This means that two common types of operations are not possible on this data type:

1. Cell-wise operations like thresholding
2. Dimension-reducing operations like contouring

Cell wise operations can easily be fixed by adding cells. This can be done with `cast_to_polydata()`

Dimension-reducing operations, on the other hand, have no solution and should not be allowed on `PointSet`.

How can we properly error out or convert to `PolyData` when calling dataset filters like `threshold()` and `contour()`? Should these types of filters be overridden on the `PointSet` class?

### Steps to reproduce the bug.

### Cell wise operation produces *invalid* output

```python
import pyvista as pv
import numpy as np
pc = pv.PointSet(np.random.random((100, 3)))
pc['foo'] = np.arange(pc.n_points)
pc.threshold()
```

<img width="575" alt="Screen Shot 2023-01-11 at 5 47 02 PM 1" src="https://user-images.githubusercontent.com/22067021/211949301-8d10e9ac-172e-4f27-ad81-c3ec2d335263.png">


### Dimension reducing operation produces *no* output

```py
import pyvista as pv
import numpy as np
pc = pv.PointSet(np.random.random((100, 3)))
pc['foo'] = np.arange(pc.n_points)
pc.contour()
```
<img width="417" alt="Screen Shot 2023-01-11 at 5 47 57 PM" src="https://user-images.githubusercontent.com/22067021/211949430-a3e77292-6b1e-4d2d-b2e3-b2a640ed65fc.png">



### System Information

```shell
n/a
```


### Screenshots

n/a
