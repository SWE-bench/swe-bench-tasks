circle creates creates one zero length edge
### Describe the bug, what's wrong, and what you expected.

I expected that:
> circle = pv.Circle(radius, resolution=n)

1. would create a circle with n points and edge. 
It does yay :-) 

3. That each edge of the would have similar length.
It does _not_ :-(

The problems seems circle  closed is doubly:
- once by the coordinates (circle.points[:, 0] == approx(circle.points[:, -1])
- and a second time by the face (circle.faces[0] == [n, 0, 1, 2, ... n-1])





### Steps to reproduce the bug.

```python
import pyvista as pv

circle = pv.Circle(radius=1, resolution=4) # lets make a low res circle
print(circle.faces)  # out: array([4, 0, 1, 2, 3])
print(circle.n_points)  # out: 4

# the print outputs gives the expectation that circle.plot() will look like a square 
circle.plot()
```
![pv.Circle(radius=1, resolution=4).plot()](https://user-images.githubusercontent.com/107837123/207049939-9b24ac31-a8e8-4ca7-97d3-3f4105a524dc.png)




### System Information

```shell
--------------------------------------------------------------------------------
  Date: Mon Dec 12 13:55:16 2022 CET

                OS : Linux
            CPU(s) : 8
           Machine : x86_64
      Architecture : 64bit
       Environment : IPython
       GPU Details : error

  Python 3.10.4 (main, Mar 23 2022, 20:25:24) [GCC 11.3.0]

           pyvista : 0.36.1
               vtk : 9.1.0
             numpy : 1.23.5
           imageio : 2.22.4
           appdirs : 1.4.4
            scooby : 0.7.0
        matplotlib : 3.6.2
         pyvistaqt : 0.9.0
             PyQt5 : Version unknown
           IPython : 8.2.0
             scipy : 1.9.3
--------------------------------------------------------------------------------
```


### Screenshots

_No response_
