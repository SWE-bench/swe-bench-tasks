Here are the top entries I see with `%prun cropped.to_xarray()`:
```
         308597 function calls (308454 primitive calls) in 0.651 seconds

   Ordered by: internal time

   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
   100000    0.255    0.000    0.275    0.000 datetimes.py:606(<lambda>)
        1    0.165    0.165    0.165    0.165 {built-in method pandas._libs.lib.is_datetime_with_singletz_array}
        1    0.071    0.071    0.634    0.634 {method 'get_indexer' of 'pandas._libs.index.BaseMultiIndexCodesEngine' objects}
        1    0.054    0.054    0.054    0.054 {pandas._libs.lib.fast_zip}
        1    0.029    0.029    0.304    0.304 {pandas._libs.lib.map_infer}
   100009    0.011    0.000    0.011    0.000 datetimelike.py:232(freq)
        9    0.010    0.001    0.010    0.001 {pandas._libs.lib.infer_dtype}
   100021    0.010    0.000    0.010    0.000 datetimes.py:684(tz)
        1    0.009    0.009    0.009    0.009 {built-in method pandas._libs.tslib.array_to_datetime}
        2    0.008    0.004    0.008    0.004 {method 'get_indexer' of 'pandas._libs.index.IndexEngine' objects}
        1    0.008    0.008    0.651    0.651 dataarray.py:1827(from_series)
    66/65    0.005    0.000    0.005    0.000 {built-in method numpy.core.multiarray.array}
    24/22    0.001    0.000    0.362    0.016 base.py:677(_values)
       17    0.001    0.000    0.001    0.000 {built-in method numpy.core.multiarray.empty}
    19/18    0.001    0.000    0.189    0.010 base.py:4914(_ensure_index)
        5    0.001    0.000    0.001    0.000 {method 'repeat' of 'numpy.ndarray' objects}
        2    0.001    0.000    0.001    0.000 {method 'tolist' of 'numpy.ndarray' objects}
        2    0.001    0.000    0.001    0.000 {pandas._libs.algos.take_1d_object_object}
        4    0.001    0.000    0.001    0.000 {pandas._libs.algos.take_1d_int64_int64}
     1846    0.001    0.000    0.001    0.000 {built-in method builtins.isinstance}
       16    0.001    0.000    0.001    0.000 {method 'reduce' of 'numpy.ufunc' objects}
        1    0.001    0.001    0.001    0.001 {method 'get_indexer' of 'pandas._libs.index.DatetimeEngine' objects}
```

There seems to be a suspiciously large amount of effort applying a function to individual datetime objects.
When I stepped through, it was by-and-large all taken up by https://github.com/pydata/xarray/blob/master/xarray/core/dataset.py#L3121. That's where the boxing & unboxing of the datetimes is from.

I haven't yet discovered how the alternative path avoids this work. If anyone has priors please lmk!
It's 3x faster to unstack & stack all-but-one level, vs reindexing over a filled-out index (and I think always produces the same result). 

Our current code takes the slow path.

I could make that change, but that strongly feels like I don't understand the root cause. I haven't spent much time with reshaping code - lmk if anyone has ideas.

```python

idx = cropped.index
full_idx = pd.MultiIndex.from_product(idx.levels, names=idx.names)

reindexed = cropped.reindex(full_idx)

%timeit reindexed = cropped.reindex(full_idx)
# 1 loop, best of 3: 278 ms per loop

%%timeit
stack_unstack = (
    cropped
    .unstack(list('yz'))
    .stack(list('yz'),dropna=False)
)
# 10 loops, best of 3: 80.8 ms per loop

stack_unstack.equals(reindexed)
# True
```
My working hypothesis is that pandas has a set of fast routines in C, such that it can stack without reindexing to the full index. The routines only work in 1-2 dimensions.

So without some hackery (i.e. converting multi-dimensional arrays to pandas' size and back), the current implementation is reasonable*. Next step would be to write our own routines that can operate on multiple dimensions (numbagg!).

Is that consistent with others' views, particularly those who know this area well?

'* one small fix that would improve performance of `series.to_xarray()` only, is the [comment above](https://github.com/pydata/xarray/issues/2459#issuecomment-426483497). Lmk if you think worth making that change
The vast majority of the time in xarray's current implementation seems to be spent in `DataFrame.reindex()`, but I see no reason why this operations needs to be so slow. I expect we could probably optimize this significantly on the pandas side.

See these results from line-profiler:
```
In [8]: %lprun -f xarray.Dataset.from_dataframe cropped.to_xarray()
Timer unit: 1e-06 s

Total time: 0.727191 s
File: /Users/shoyer/dev/xarray/xarray/core/dataset.py
Function: from_dataframe at line 3094

Line #      Hits         Time  Per Hit   % Time  Line Contents
==============================================================
  3094                                               @classmethod
  3095                                               def from_dataframe(cls, dataframe):
  3096                                                   """Convert a pandas.DataFrame into an xarray.Dataset
  3097
  3098                                                   Each column will be converted into an independent variable in the
  3099                                                   Dataset. If the dataframe's index is a MultiIndex, it will be expanded
  3100                                                   into a tensor product of one-dimensional indices (filling in missing
  3101                                                   values with NaN). This method will produce a Dataset very similar to
  3102                                                   that on which the 'to_dataframe' method was called, except with
  3103                                                   possibly redundant dimensions (since all dataset variables will have
  3104                                                   the same dimensionality).
  3105                                                   """
  3106                                                   # TODO: Add an option to remove dimensions along which the variables
  3107                                                   # are constant, to enable consistent serialization to/from a dataframe,
  3108                                                   # even if some variables have different dimensionality.
  3109
  3110         1        352.0    352.0      0.0          if not dataframe.columns.is_unique:
  3111                                                       raise ValueError(
  3112                                                           'cannot convert DataFrame with non-unique columns')
  3113
  3114         1          3.0      3.0      0.0          idx = dataframe.index
  3115         1        356.0    356.0      0.0          obj = cls()
  3116
  3117         1          2.0      2.0      0.0          if isinstance(idx, pd.MultiIndex):
  3118                                                       # it's a multi-index
  3119                                                       # expand the DataFrame to include the product of all levels
  3120         1       4524.0   4524.0      0.6              full_idx = pd.MultiIndex.from_product(idx.levels, names=idx.names)
  3121         1     717008.0 717008.0     98.6              dataframe = dataframe.reindex(full_idx)
  3122         1          3.0      3.0      0.0              dims = [name if name is not None else 'level_%i' % n
  3123         1         20.0     20.0      0.0                      for n, name in enumerate(idx.names)]
  3124         4          9.0      2.2      0.0              for dim, lev in zip(dims, idx.levels):
  3125         3       2973.0    991.0      0.4                  obj[dim] = (dim, lev)
  3126         1         37.0     37.0      0.0              shape = [lev.size for lev in idx.levels]
  3127                                                   else:
  3128                                                       dims = (idx.name if idx.name is not None else 'index',)
  3129                                                       obj[dims[0]] = (dims, idx)
  3130                                                       shape = -1
  3131
  3132         2        350.0    175.0      0.0          for name, series in iteritems(dataframe):
  3133         1         33.0     33.0      0.0              data = np.asarray(series).reshape(shape)
  3134         1       1520.0   1520.0      0.2              obj[name] = (dims, data)
  3135         1          1.0      1.0      0.0          return obj
```
@max-sixty nevermind, you seem to have already discovered that :)
I've run into this twice. This time I'm seeing a difference of very roughly 100x or more just using a transpose -- I can't test or time it properly right now, but this is what it looks like:

```
ipdb> df
x              a       b  ...    c      d
y              0       0  ...    7      7
z                         ...            
0       0.000000     0.0  ...  0.0    0.0
1      -0.000416     0.0  ...  0.0    0.0

[2 rows x 2932 columns]
ipdb> df.to_xarray()

<I quit out because it takes at least 30s>

ipdb> df.T.to_xarray()

<Finishes instantly>

```

@tqfjo unrelated. You're comparing the creation of a dataset with 2 variables with the creation of one with 3000. Unsurprisingly, the latter will take 1500x. If your dataset doesn't functionally contain 3000 variables but just a single two-dimensional variable, use ``xarray.DataArray(ds)``.
@crusaderky Thanks for the pointer to `xarray.DataArray(df)` -- that makes my life a ton easier. 

<br>

That said, if it helps anyone to know, I did just want a `DataArray`, but figured there was no alternative to first running the rather singular `to_xarray`. I also still find the runtime surprising, though I know nothing about `xarray`'s internals.




I know this is not a recent thread but I found no resolution, and we just ran in the same issue recently. In our case we had a pandas series of roughly 15 milliion entries, with a 3-level multi-index which had to be converted to an xarray.DataArray. The .to_xarray took almost 2 minutes. Unstack + to_array took it down to roughly 3 seconds, provided the last level of the multi index was unstacked. 

However a much faster solution was through numpy array. The below code is based on the [idea of Igor Raush](https://stackoverflow.com/a/35049899)

(In this case df is a dataframe with a single column, or a series)
```
arr = np.full(df.index.levshape, np.nan)
arr[tuple(df.index.codes)] = df.values.flat
da = xr.DataArray(arr,dims=df.index.names,coords=dict(zip(df.index.names, df.index.levels)))
```


Hi All. I stumble across the same issue trying to convert a 5000 column dataframe to xarray (it was never going to happen...).
I found a workaround and I am posting the test below. Hope it helps.

```python
import xarray as xr
import pandas as pd
import numpy as np

xr.__version__

    '0.15.1'

pd.__version__

    '1.0.5'

df = pd.DataFrame(np.random.randn(200, 500))

%%time
one = df.to_xarray()

    CPU times: user 29.6 s, sys: 60.4 ms, total: 29.6 s
    Wall time: 29.7 s

%%time
dic={}
for name in df.columns:
    dic.update({name:(['index'],df[name].values)})

two = xr.Dataset(dic, coords={'index': ('index', df.index.values)})         

    CPU times: user 17.6 ms, sys: 158 µs, total: 17.8 ms
    Wall time: 17.8 ms

one.equals(two)

    True

```
