Adding ``CircularArc``s together does not provide a line
### Describe the bug, what's wrong, and what you expected.

Don't know if it can be considered a bug or not but...

If you define two consecutive ``pv.CircularArc`` and you plot them, weird things start to appear with the new PyVista 0.39 version. Run the following code snippet using ``pyvista==0.38.6`` and ``pyvista==0.39.0``

### Steps to reproduce the bug.

```python
import pyvista as pv


# Define your arcs
#
#              Y       (s2)
#              ^   ____(e1)____
#              |  /             \
#              | /               \
#              |/                 \
#          (s1)O ------(c)-------(e2)----> X
#
#   Let's imagine the above is an arc from (0,0) to (10,10) and origin
#   at (10,0); and another consecutive arc from (10,10) to (20,0) and
#   origin at (10,0)
#
arc_1 = pv.CircularArc([0, 0, 0], [10, 10, 0], [10, 0, 0], negative=False)
arc_2 = pv.CircularArc([10, 10, 0], [20, 0, 0], [10, 0, 0], negative=False)

# ========== CRITICAL BEHAVIOR ==========
# I add them together
arc = arc_1 + arc_2
# ========== CRITICAL BEHAVIOR ==========

# Instantiate plotter
pl = pv.Plotter()

# Add the polydata
pl.add_mesh(arc)

# Plotter config: view from the top
pl.view_vector(vector=[0, 0, 1], viewup=[0, 1, 0])

# Plot
pl.show()

```

### System Information

```shell
For PyVista 0.38.6

--------------------------------------------------------------------------------
  Date: Thu May 11 13:49:09 2023 Romance Daylight Time

                OS : Windows
            CPU(s) : 16
           Machine : AMD64
      Architecture : 64bit
       Environment : Python
        GPU Vendor : Intel
      GPU Renderer : Intel(R) UHD Graphics
       GPU Version : 4.5.0 - Build 30.0.100.9955

  Python 3.10.11 (tags/v3.10.11:7d4cc5a, Apr  5 2023, 00:38:17) [MSC v.1929 64
  bit (AMD64)]

           pyvista : 0.38.6
               vtk : 9.2.6
             numpy : 1.24.3
           imageio : 2.28.1
            scooby : 0.7.2
             pooch : v1.7.0
        matplotlib : 3.7.1
--------------------------------------------------------------------------------

For PyVista 0.39.0

--------------------------------------------------------------------------------
  Date: Thu May 11 13:50:00 2023 Romance Daylight Time

                OS : Windows
            CPU(s) : 16
           Machine : AMD64
      Architecture : 64bit
       Environment : Python
        GPU Vendor : Intel
      GPU Renderer : Intel(R) UHD Graphics
       GPU Version : 4.5.0 - Build 30.0.100.9955
  MathText Support : False

  Python 3.10.11 (tags/v3.10.11:7d4cc5a, Apr  5 2023, 00:38:17) [MSC v.1929 64
  bit (AMD64)]

           pyvista : 0.39.0
               vtk : 9.2.6
             numpy : 1.24.3
        matplotlib : 3.7.1
            scooby : 0.7.2
             pooch : v1.7.0
--------------------------------------------------------------------------------
```


### Screenshots

PyVista 0.39

![PyVista 0.39](https://github.com/pyvista/pyvista/assets/37798125/87bda0a2-2eb7-4171-8005-239f5a4f27c2)

PyVista 0.38.6

![PyVista 0.38.6](https://github.com/pyvista/pyvista/assets/37798125/b6159e12-97bc-4768-9691-91005fadfb26)

