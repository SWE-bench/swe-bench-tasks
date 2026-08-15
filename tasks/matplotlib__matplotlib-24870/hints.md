Sounds reasonable. Levels has an automatic default. If we can make that better for bool arrays, let's do it.

Side-remark: I tried your code with `contourf()`, but that raises "Filled contours require at least 2 levels". Maybe you want to look at that as well?
For contourf(bool_array) the natural levels would be [0, .5, 1]; sure that can go together with fixing contour.