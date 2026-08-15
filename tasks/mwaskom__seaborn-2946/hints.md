Thanks for reporting, I can reproduce. This is a weird one!
I think this is the fundamental issue, and I do not understand what pandas as doing here:

```python
def custom_min_asarray(x):
    return np.asarray(x).min()
tips["tip"].agg(custom_min_asarray)
```
```
0      1.01
1      1.66
2      3.50
3      3.31
4      3.61
       ... 
239    5.92
240    2.00
241    2.00
242    1.75
243    3.00
Name: tip, Length: 244, dtype: float64
```

```python
def custom_min_native(x):
    return x.min()
tips["tip"].agg(custom_min_native)
```
```
1.0
```
OK I think I kind of understand, but also wtf. I gather that `Series.agg(f)` first tries `Series.apply(f)`. That passes numbers into the function so, if you're calling a numeric method, it fails. But `np.asarray(x).min()` where x is a scalar will produce a 0-dimensional array and then call `.min()` on it, which is valid. So `.agg` doesn't actually reduce, which then blows up downstream.

Argh.
I think we ran into https://github.com/pandas-dev/pandas/issues/46581 , as seaborn does `Series.agg` here: https://github.com/mwaskom/seaborn/blob/9771eae42a802f898f95c6b062f036bd7940e6b4/seaborn/_statistics.py#L481
This explains the change from 0.11.2 which was calling the estimator with the series as input:
https://github.com/mwaskom/seaborn/blob/10fc8d74e7686ead56e6f621413926114d470daa/seaborn/categorical.py#L1520

Yep the intention of that change was to support `estimator: str` in a clean way. I guess we can change it to something like

```python
if callable(self.estimator):
    estimate = self.estimator(vals)
else:
    estimate = vals.agg(self.estimator)
```