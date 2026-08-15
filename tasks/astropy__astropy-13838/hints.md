The root cause of this is that astropy delegates to numpy to convert a list of values into a numpy array. Notice the differences in output `dtype` here:
```
In [25]: np.array([[], []])
Out[25]: array([], shape=(2, 0), dtype=float64)

In [26]: np.array([[], [], [1, 2]])
Out[26]: array([list([]), list([]), list([1, 2])], dtype=object)
```
In your example you are expecting an `object` array of Python `lists` in both cases, but making this happen is not entirely practical since we rely on numpy for fast and general conversion of inputs.

The fact that a `Column` with a shape of `(2,0)` fails to print is indeed a bug, but for your use case it is likely not the real problem. In your examples if you ask for the `.info` attribute you will see this reflected.

As a workaround, a reliable way to get a true object array is something like:
```
t = Table()
col = [[], []]
t["c"] = np.empty(len(col), dtype=object)
t["c"][:] = [[], []]
print(t)
 c 
---
 []
 []
```
