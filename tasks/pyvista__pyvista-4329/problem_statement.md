PolyData faces array is not updatable in-place and has unexpected behavior
### Describe the bug, what's wrong, and what you expected.

When accessing `PolyData.faces` (and likely other cell data), we cannot update the array in place. Further, there is some unexpected behavior where accessing `PolyData.faces` will override existing, modified views of the array.

### Steps to reproduce the bug.

```python 
>>> import pyvista as pv
>>> mesh = pv.Sphere()
>>> f = mesh.faces
>>> f
array([  3,   2,  30, ..., 840,  29,  28])
>>> a = f[1:4]
>>> a
array([ 2, 30,  0])
>>> b = f[5:8]
>>> b
array([30, 58,  0])
>>> f[1:4] = b
>>> f[5:8] = a
>>> f
array([  3,  30,  58, ..., 840,  29,  28])
>>> assert all(f[1:4] == b) and all(f[5:8] == a)
>>> mesh.faces  # access overwrites `f` in place which is unexpected and causes the check above to now fail
>>> assert all(f[1:4] == b) and all(f[5:8] == a)
---------------------------------------------------------------------------
AssertionError                            Traceback (most recent call last)
<ipython-input-82-08205e08097f> in <cell line: 13>()
     11 assert all(f[1:4] == b) and all(f[5:8] == a)
     12 mesh.faces  # access overwrites `f` in place
---> 13 assert all(f[1:4] == b) and all(f[5:8] == a)

AssertionError: 
 ```

### System Information

```shell
--------------------------------------------------------------------------------
  Date: Thu May 26 11:45:54 2022 MDT

                OS : Darwin
            CPU(s) : 16
           Machine : x86_64
      Architecture : 64bit
               RAM : 64.0 GiB
       Environment : Jupyter
       File system : apfs
        GPU Vendor : ATI Technologies Inc.
      GPU Renderer : AMD Radeon Pro 5500M OpenGL Engine
       GPU Version : 4.1 ATI-4.8.13

  Python 3.8.8 | packaged by conda-forge | (default, Feb 20 2021, 16:12:38)
  [Clang 11.0.1 ]

           pyvista : 0.35.dev0
               vtk : 9.1.0
             numpy : 1.22.1
           imageio : 2.9.0
           appdirs : 1.4.4
            scooby : 0.5.12
        matplotlib : 3.5.2
           IPython : 7.32.0
          colorcet : 3.0.0
           cmocean : 2.0
        ipyvtklink : 0.2.2
             scipy : 1.8.0
        itkwidgets : 0.32.1
              tqdm : 4.60.0
            meshio : 5.3.4
--------------------------------------------------------------------------------
```


### Screenshots

_No response_

### Code of Conduct

- [X] I agree to follow this project's Code of Conduct
