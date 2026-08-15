To be checked: Can the same effect occur when using (numpy) int arrays?
Just a note that `np.hist(float16)` returns `float16` edges.

You may want to try using "stairs" here instead, which won't draw the bars all the way down to zero and help avoid those artifacts.
`plt.stairs(*np.histogram(values, bins=100), fill=True, alpha=0.5)`
I am not sure, but it seems like possibly a problem in NumPy.

```
In[9]: cnt, bins = np.histogram(values, 100)

In [10]: bins
Out[10]: 
array([0.  , 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1 ,
       0.11, 0.12, 0.13, 0.14, 0.15, 0.16, 0.17, 0.18, 0.19, 0.2 , 0.21,
       0.22, 0.23, 0.24, 0.25, 0.26, 0.27, 0.28, 0.29, 0.3 , 0.31, 0.32,
       0.33, 0.34, 0.35, 0.36, 0.37, 0.38, 0.39, 0.4 , 0.41, 0.42, 0.43,
       0.44, 0.45, 0.46, 0.47, 0.48, 0.49, 0.5 , 0.51, 0.52, 0.53, 0.54,
       0.55, 0.56, 0.57, 0.58, 0.59, 0.6 , 0.61, 0.62, 0.63, 0.64, 0.65,
       0.66, 0.67, 0.68, 0.69, 0.7 , 0.71, 0.72, 0.73, 0.74, 0.75, 0.76,
       0.77, 0.78, 0.79, 0.8 , 0.81, 0.82, 0.83, 0.84, 0.85, 0.86, 0.87,
       0.88, 0.89, 0.9 , 0.91, 0.92, 0.93, 0.94, 0.95, 0.96, 0.97, 0.98,
       0.99, 1.  ], dtype=float16)

In [11]: np.diff(bins)
Out[11]: 
array([0.01    , 0.01    , 0.009995, 0.01001 , 0.00998 , 0.01001 ,
       0.01001 , 0.01001 , 0.01001 , 0.00995 , 0.01001 , 0.01001 ,
       0.01001 , 0.01001 , 0.01001 , 0.01001 , 0.01001 , 0.01001 ,
       0.00989 , 0.01001 , 0.01001 , 0.01001 , 0.01001 , 0.01001 ,
       0.01001 , 0.01001 , 0.01001 , 0.01001 , 0.01001 , 0.01001 ,
       0.01001 , 0.01001 , 0.01001 , 0.01001 , 0.01001 , 0.01001 ,
       0.01001 , 0.009766, 0.01001 , 0.01001 , 0.01001 , 0.01001 ,
       0.01001 , 0.01001 , 0.01001 , 0.01001 , 0.01001 , 0.01001 ,
       0.01001 , 0.01001 , 0.009766, 0.010254, 0.009766, 0.010254,
       0.009766, 0.010254, 0.009766, 0.010254, 0.009766, 0.010254,
       0.009766, 0.010254, 0.009766, 0.010254, 0.009766, 0.010254,
       0.009766, 0.010254, 0.009766, 0.010254, 0.009766, 0.010254,
       0.009766, 0.010254, 0.009766, 0.009766, 0.010254, 0.009766,
       0.010254, 0.009766, 0.010254, 0.009766, 0.010254, 0.009766,
       0.010254, 0.009766, 0.010254, 0.009766, 0.010254, 0.009766,
       0.010254, 0.009766, 0.010254, 0.009766, 0.010254, 0.009766,
       0.010254, 0.009766, 0.010254, 0.009766], dtype=float16)
```

It looks like the diff is not really what is expected.
~I am actually a bit doubtful if the bins are really float16 here though.~ I guess they are, since it is float16, not bfloat16.
It is possible to trigger it with quite high probability using three bins, so that may be an easier case to debug (second and third bar overlap). Bin edges and diff seems to be the same independent of overlap or not.

```
In [44]: bins
Out[44]: array([0.    , 0.3333, 0.6665, 1.    ], dtype=float16)

In [45]: np.diff(bins)
Out[45]: array([0.3333, 0.3333, 0.3335], dtype=float16)
```
There is an overlap in the plot data (so it is not caused by the actual plotting, possibly rounding the wrong way):

```
In [98]: bc.patches[1].get_corners()
Out[98]: 
array([[3.33251953e-01, 0.00000000e+00],
       [6.66992188e-01, 0.00000000e+00],
       [6.66992188e-01, 4.05000000e+02],
       [3.33251953e-01, 4.05000000e+02]])

In [99]: bc.patches[2].get_corners()
Out[99]: 
array([[  0.66601562,   0.        ],
       [  0.99951172,   0.        ],
       [  0.99951172, 314.        ],
       [  0.66601562, 314.        ]])
``` 
As the second bar ends at 6.66992188e-01 and the third bar starts at 0.66601562, this will happen.
A possibly easy way to solve this is to provide a keyword argument to `bar`/`barh` that makes sure that the bars are always adjacent, i.e., let `bar`/`barh` know that the next bar should have the same starting point as the previous bars end point. That keyword argument can then be called from from `hist` in case of an `rwidth` of 1.
This is probably the line causing the error:
https://github.com/matplotlib/matplotlib/blob/8b1881fd49b49bf85a7b91575f4653be41c26294/lib/matplotlib/axes/_axes.py#L2382
Something like `np.diff(np.cumsum(x) - width/2)` may work, but should then only be conditionally executed if the keyword argument is set.

(Then, I am not sure to what extent np.diff and np.cumsum are 100% numerically invariant, it is not trivial under floating-point arithmetic. But probably this will reduce the probability of errors anyway.)
> To be checked: Can the same effect occur when using (numpy) int arrays?

Yes and no. As the int array will become a float64 after multiplying with a float (dr in the code), it is quite unlikely to happen. However, it is not theoretically impossible to obtain the same effect with float64, although not very likely that it will actually be seen in a plot (the accumulated numerical error should correspond to something close to half(?) a pixel). But I am quite sure that one can trigger this by trying.
If you force the bins to be float64, then you won't have this problem:

```python
import numpy as np
import matplotlib.pyplot as plt
values = np.clip(np.random.normal(0.5, 0.3, size=1000), 0, 1).astype(np.float16)
n, bins = np.histogram(values, bins=100)
n, bins, patches = plt.hist(values, bins=np.array(bins, dtype='float64'), alpha=0.5)

plt.show()
```
so I think the reasonable fix here is simply for matplotlib to coerce the output from `np.histogram` to be floats - the output is turned to float64 when rendered anyways, and the extra memory for any visible number of bins is not going to matter.  

Is the numerical problem the diff?   Would it make sense to just convert the numpy bin edges to float64 before the diff?
> Is the numerical problem the diff? 

Hard to say. But the problem is that one does quite a bit of computations and at some stage there are rounding errors that leads to that there are overlaps or gaps between edges. So postponing diff will reduce the risk that this happens (on the other hand, one may get cancellations as a result, but I do not think that will happen more now since the only things we add here are about the same order of magnitude).

> Would it make sense to just convert the numpy bin edges to float64 before the diff?

Yes, or even float32, but as argued in the issue, one tend to use float16 for memory limited environments, so not clear if one can afford it.

Here, I am primarily trying to see the effect of it. As we do not deal with all involved computations here, some are also in `bar`/`barh`, the better approach may be to use a flag, "fill", or something that makes sure that all edges are adjacent if set (I'm quite sure a similar problem can arise if feeding `bar`-edges in `float16` as well.
It seems like we do not have any test images that are negatively affected by this at least... But it may indeed not be the best solution to the problem.


Ahh, but even if the data to hist is `float16`, the actual histogram array doesn't have to be that... And that is probably much smaller compared to the data. So probably a simpler fix is to change the data type of the histogram data before starting to process it...
I think you just want another type catch here (I guess I'm not sure the difference between `float` and `"float64"`), or at least that fixes the problem for me.

```diff
diff --git a/lib/matplotlib/axes/_axes.py b/lib/matplotlib/axes/_axes.py
index f1ec9406ea..88d90294a3 100644
--- a/lib/matplotlib/axes/_axes.py
+++ b/lib/matplotlib/axes/_axes.py
@@ -6614,6 +6614,7 @@ such objects
             m, bins = np.histogram(x[i], bins, weights=w[i], **hist_kwargs)
             tops.append(m)
         tops = np.array(tops, float)  # causes problems later if it's an int
+        bins = np.array(bins, float)  # causes problems is float16!
         if stacked:
             tops = tops.cumsum(axis=0)
             # If a stacked density plot, normalize so the area of all the
```
> I guess I'm not sure the difference between float and "float64"

Numpy accepts builtin python types and maps them to numpy types:

https://numpy.org/doc/stable/reference/arrays.dtypes.html#specifying-and-constructing-data-types
(scroll a bit to "Built-in Python types").

The mapping can be platform specific. E.g. `int` maps to `np.int64` on linux but `np.int32` on win.
`float` maps on x86 linux and win to `np.float64`. But I don't know if that's true on arm etc.