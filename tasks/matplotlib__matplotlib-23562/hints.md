Ok, I have a "fix", in the sense that that attribute will be defined upon initialization. However, for your example, the facecolors returned is completely useless ([[0, 0, 1, 1]] -- all blue, which is default). I suspect that there is a deeper problem with ScalarMappables in general in that they don't set their facecolors until draw time?

The solution is to probably force the evaluation of the norm + cmap in `get_facecolors`.

The bigger question I have is if regular PolyCollections that are
ScalarMappables suffer from the same problem?

On Sat, Feb 7, 2015 at 6:42 PM, Thomas A Caswell notifications@github.com
wrote:

> The solution is to probably force the evaluation of the norm + cmap in
> get_facecolors.
> 
> —
> Reply to this email directly or view it on GitHub
> https://github.com/matplotlib/matplotlib/issues/4067#issuecomment-73389124
> .

PR #4090 addresses this.  Although, it still doesn't return any useful
value... it just does the same thing that regular PolyCollections do.

On Mon, Feb 9, 2015 at 3:47 PM, Thomas A Caswell notifications@github.com
wrote:

> Assigned #4067 https://github.com/matplotlib/matplotlib/issues/4067 to
> @WeatherGod https://github.com/WeatherGod.
> 
> —
> Reply to this email directly or view it on GitHub
> https://github.com/matplotlib/matplotlib/issues/4067#event-232758504.

I believe I'm still running into this issue today. Below is the error message I receive when attempting to convert hb_made (a hexbin PolyCollection) into a Poly3DCollection. Are there any other ways to convert 2D PolyCollections into 3D PolyCollections?

```
ax.add_collection3d(hb_made, zs=shotNumber.get_array(), zdir='y')
```

  File "/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/mpl_toolkits/mplot3d/axes3d.py", line 2201, in add_collection3d
    art3d.poly_collection_2d_to_3d(col, zs=zs, zdir=zdir)
  File "/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/mpl_toolkits/mplot3d/art3d.py", line 716, in poly_collection_2d_to_3d
    col.set_3d_properties()
  File "/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/mpl_toolkits/mplot3d/art3d.py", line 595, in set_3d_properties
    self._edgecolors3d = PolyCollection.get_edgecolors(self)
  File "/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/matplotlib/collections.py", line 626, in get_edgecolor
    return self.get_facecolors()
  File "/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/mpl_toolkits/mplot3d/art3d.py", line 699, in get_facecolors
    return self._facecolors2d
AttributeError: 'Poly3DCollection' object has no attribute '_facecolors2d'

I don't know if this is the appropriate place to post this, but here is a temporary fix for anyone who is waiting on the permanent fix.

I encounter this same error when trying to add a legend to my 3D surface plot.

```
surf = axarr[0].plot_surface(XSrc, YAmb, XCorrMeanDepthErrs[CodingScheme], label=CodingScheme, 
						alpha=.5, facecolor=color, edgecolor='black', linewidth=2)
axarr[0].legend()
```

While a permanent fix is find, I found that a simple temporary fix is to explicitly set the `_facecolors2d` and `_edgecolors2d` parameters after creating the surface plot.

```
surf = axarr[0].plot_surface(XSrc, YAmb, XCorrMeanDepthErrs[CodingScheme], label=CodingScheme, 
						alpha=.5, facecolor=color, edgecolor='black', linewidth=2)
surf._facecolors2d=surf._facecolors3d
surf._edgecolors2d=surf._edgecolors3d
axarr[0].legend()
```

I also could not get the legend to show in my 3d plot of planes with the error:"AttributeError: 'Poly3DCollection' object has no attribute '_edgecolors2d'". 

Although the fix from @felipegb94 worked: 
surf._facecolors2d=surf._facecolors3d
surf._edgecolors2d=surf._edgecolors3d


I'm remilestoning this to keep it on the radar. 
I run into this today, but now even the workaround (https://github.com/matplotlib/matplotlib/issues/4067#issuecomment-357794003) is not working any more.
I ran into this today, with version 3.3.1.post1012+g5584ba764, the workaround did the trick.
I ran in to this as well, and the fix works in version 3.3.1 but not in 3.3.3
@bootje2000 Apparently some attributes have been renamed or moved around (prima facie). Try this slight modification to @felipegb94's workaround:
```
surf._facecolors2d = surf._facecolor3d
surf._edgecolors2d = surf._edgecolor3d
```
Note the lack of "s" on the RHS. `_facecolors3d` and `_edgecolors3d` do not seem to exist anymore.

This works in `matplotlib 3.3.3` as of January 04, 2021.
None of the workarounds work in matplotlib 3.5.1
It works after modifying for the available attributes `_facecolors `and `_edgecolors`:
`surf._facecolors2d = surf._facecolors`
`surf._edgecolors2d = surf._edgecolors`

Hint: if there are multiple surfaces on the same axes, the workaround must be applied to each surface individually.
@nina-wwc I just checked the minimal working example in this thread using `matplotlib-3.5.1` and `3.5.2` (latest) and my workaround works as it did before, as does yours. Could you test the example code in a virtual environment perhaps, if you haven't already done so?
The problem still is that we update some state during the draw process.  Internally we do the updating and the access in just the right order so that in most cases we do not notice that we also add the attributes on the fly. 

The best workaround for the current case (assuming 3.5):

```python
import numpy as np
import matplotlib.tri as mtri
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

y,x = np.ogrid[1:10:100j, 1:10:100j]
z2 = np.cos(x)**3 - np.sin(y)**2
fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
r = ax.plot_surface(x,y,z2, cmap='hot')
fig.draw_without_rendering()   # <--- This is the key line
r.get_facecolors()
```

However, I still think the best solution is https://github.com/matplotlib/matplotlib/issues/4067#issuecomment-73389124 which will require looking in `get_facecolors` to detect when these attributes are missing (and if stale?) and then force what ever needs to be done to update them.

Labeling this as a good first issue because it clearly has affected a lot of people for a long time, there is a very clear reproduction example (that will make a perfect test), and there are no API design choices to be made, but medium difficulty because it will require understanding some slightly tricking inheritance and how our 3D artists draw them selves. 