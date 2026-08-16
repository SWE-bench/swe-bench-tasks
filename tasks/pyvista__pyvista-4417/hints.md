I can reproduce this problem. We'll add it for the v0.39.1 milestone.
The trick is this bit of code:

https://github.com/pyvista/pyvista/blob/a8921b94b91a7d9809c9b5ac2ef9c981b5f71ea1/pyvista/plotting/plotting.py#L3218-L3224

which isn't used for `MultiBlock` plotting because `add_mesh` forwards to `add_composite()`

https://github.com/pyvista/pyvista/blob/a8921b94b91a7d9809c9b5ac2ef9c981b5f71ea1/pyvista/plotting/plotting.py#L3230

But then I realized this block should handle it

https://github.com/pyvista/pyvista/blob/a8921b94b91a7d9809c9b5ac2ef9c981b5f71ea1/pyvista/plotting/plotting.py#L2544


so maybe there's a bug in that method or the copy isn't propagating? Not sure...

