Boolean Operation freezes/crashes 
### Describe the bug, what's wrong, and what you expected.

Apparently, if two polyData have the exact same shape, their boolean operation freezes/crashes the application!


### Steps to reproduce the bug.

```python
p1 = pv.Sphere().triangulate()
p2 = pv.Sphere().triangulate()

p1.boolean_intersection(p2)
``````

### System Information

```shell
--------------------------------------------------------------------------------
  Date: Tue Aug 22 12:17:01 2023 EEST

                OS : Darwin
            CPU(s) : 12
           Machine : x86_64
      Architecture : 64bit
               RAM : 16.0 GiB
       Environment : Jupyter
       File system : apfs
        GPU Vendor : ATI Technologies Inc.
      GPU Renderer : AMD Radeon Pro 5300M OpenGL Engine
       GPU Version : 4.1 ATI-4.14.1
  MathText Support : False

  Python 3.10.11 (v3.10.11:7d4cc5aa85, Apr  4 2023, 19:05:19) [Clang 13.0.0
  (clang-1300.0.29.30)]

           pyvista : 0.41.1
               vtk : 9.2.6
             numpy : 1.24.2
        matplotlib : 3.7.1
            scooby : 0.7.2
             pooch : v1.7.0
           IPython : 8.14.0
             scipy : 1.10.1
        jupyterlab : 4.0.5
      nest_asyncio : 1.5.7
--------------------------------------------------------------------------------
```


### Screenshots

_No response_
