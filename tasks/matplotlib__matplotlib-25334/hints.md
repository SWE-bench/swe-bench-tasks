@ianthomas23 would you like to look at this?  It sounds like maybe more early-stage argument checking is needed.
The assertions in `_contour.cpp` are to help with debugging, in particularly to identify when the C++ code is called with strange arguments. In this example a C++ `QuadContourGenerator` object is created for a 2D array of NaNs and then it is asked to contour a `z` level of NaN. The C++ code will walk through the 2D array looking for contours at the NaN level, not find any and return an empty contour set.

The C++ assertion is a distraction here, although it did help to identify the problem. For an array of NaNs there is no point in ever accessing the C++ contouring code as there are no contours to find. A better approach would be for the python code (`contour.py`) to identify that the `z` array is all NaNs early on and never call the C++ code.

There is a question of policy here. When trying to contour an array of NaNs, do we (1) report a warning and return a valid but empty contour set, or (2) raise an exception instead?
I think the prevailing policy, and a good one, is to return empty but valid objects, like this:
```
In [5]: plt.plot([np.nan], [np.nan])
[<matplotlib.lines.Line2D at 0x120171cf8>]
```
The current behavior as of master is to spit out a lot of warnings, but actually draw the figure (original example from above):

~~~
In [5]: plt.contour(x)                                                                     
/home/tim/dev/matplotlib/lib/matplotlib/contour.py:1498: UserWarning: Warning: converting a masked element to nan.
  self.zmax = float(z.max())
/home/tim/dev/matplotlib/lib/matplotlib/contour.py:1499: UserWarning: Warning: converting a masked element to nan.
  self.zmin = float(z.min())
/home/tim/dev/matplotlib/lib/matplotlib/contour.py:1144: RuntimeWarning: invalid value encountered in less
  under = np.nonzero(lev < self.zmin)[0]
/home/tim/dev/matplotlib/lib/matplotlib/contour.py:1146: RuntimeWarning: invalid value encountered in greater
  over = np.nonzero(lev > self.zmax)[0]
/home/tim/dev/matplotlib/lib/matplotlib/contour.py:1175: RuntimeWarning: invalid value encountered in greater
  inside = (self.levels > self.zmin) & (self.levels < self.zmax)
/home/tim/dev/matplotlib/lib/matplotlib/contour.py:1175: RuntimeWarning: invalid value encountered in less
  inside = (self.levels > self.zmin) & (self.levels < self.zmax)
/home/tim/anaconda3/envs/mpl-old/bin/ipython:5: UserWarning: No contour levels were found within the data range.
  import sys
Out[4]: <matplotlib.contour.QuadContourSet at 0x7ff370747c18>
~~~

So, basically as desired. However the number of warnings could be reduced.

Implementing just one warning will be cumbersome. Either you follow the original code path but prevent all the above warnings when they occur. Or you break early, but then you have to make sure, you still get a valid `QuadContourSet` (leaving out parts of `__init__` can lead to some attributes not being defined).
Now there are fewer warnings:

```
/local/data1/matplotlib/lib/matplotlib/contour.py:1459: UserWarning: Warning: converting a masked element to nan.
  self.zmax = float(z.max())
/local/data1/matplotlib/lib/matplotlib/contour.py:1460: UserWarning: Warning: converting a masked element to nan.
  self.zmin = float(z.min())
<ipython-input-1-1b8de0dba6a5>:5: UserWarning: No contour levels were found within the data range.
```

Probably few enough to add a smoke test so that it doesn't break again and close this issue.
Marking as good first issue as it is only to create a test (using the original code above) that catches the warnings. Not sure how the catch-and-match-logic behaves with three warnings though.

Make sure to add a comment like:
```
# Smoke test for gh#14124
```
in the test.