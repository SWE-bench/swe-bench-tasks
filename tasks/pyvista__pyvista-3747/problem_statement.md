`bounds` property return type is mutable from `MultiBlock`
The `bounds` property has a different return type for meshes and `MultiBlock` objects:

```
>>> import pyvista as pv
>>> slices = pv.Sphere().slice_orthogonal()
# MultiBlock returns list (mutable)
>>> slices.bounds
[-0.49926671385765076, 0.49926671385765076, -0.4965316653251648, 0.4965316653251648, -0.5, 0.5]
# Mesh returns tuple (immutable)
>>> slices[0].bounds
(-6.162975822039155e-33, 0.0, -0.4965316653251648, 0.4965316653251648, -0.5, 0.5)
```

IMO, the return value should be immutable and the `bounds` property should  be cast to a tuple before returning.
