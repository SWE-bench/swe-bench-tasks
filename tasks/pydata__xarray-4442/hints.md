I agree, this is definitely not ideal behavior!

I hesitate to call it  a  bug only because I'm not sure if we've ever supported this  behavior.

It would be nice to fix this, and  I would encourage  you (or other interested users)  to look into it.
This seems to happen because `MultiIndex.from_product` is being passed an index and a MultiIndex, and doesn't handle this well. 

The pandas error isn't great but I think it's mostly on us)

```python
> /home/mroos/.local/lib/python3.7/site-packages/xarray/core/coordinates.py(111)to_index()
    109             indexes = [self._data.get_index(k) for k in ordered_dims]  # type: ignore
    110             names = list(ordered_dims)
--> 111             return pd.MultiIndex.from_product(indexes, names=names)
    112 
    113     def update(self, other: Mapping[Hashable, Any]) -> None:

ipdb> indexes
[Index(['0', '1', '2', '3'], dtype='object', name='n'), MultiIndex([(    18671, '1995-03-31'),
            (    18671, '1995-06-30'),
            (    18671, '1995-09-30'),
            (    18671, '1995-12-31'),
            (    18671, '1996-03-31'),
            (    18671, '1996-06-30'),
            (    18671, '1996-09-30'),
            (    18671, '1996-12-31'),
            (    18671, '1997-03-31'),
            (    18671, '1997-06-30'),
            ...
            (634127183, '2012-09-30'),
            (634127183, '2012-12-31'),
            (634127183, '2013-03-31'),
            (634127183, '2013-06-30'),
            (634127183, '2013-09-30'),
            (634127183, '2013-12-31'),
            (634127183, '2014-03-31'),
            (634127183, '2014-06-30'),
            (634127183, '2014-09-30'),
            (634127183, '2014-12-31')],
           names=['c', 'date'], length=201040)]
```

Here's the whole stack trace for reference:

```python

---------------------------------------------------------------------------
NotImplementedError                       Traceback (most recent call last)
<ipython-input-698-952a54d66d1c> in <module>
----> 1 observations.assign_coords(n=['0','1','2','3']).to_dataframe()

~/.local/lib/python3.7/site-packages/xarray/core/dataset.py in to_dataframe(self)
   4463         this dataset's indices.
   4464         """
-> 4465         return self._to_dataframe(self.dims)
   4466 
   4467     def _set_sparse_data_from_dataframe(

~/.local/lib/python3.7/site-packages/xarray/core/dataset.py in _to_dataframe(self, ordered_dims)
   4453             for k in columns
   4454         ]
-> 4455         index = self.coords.to_index(ordered_dims)
   4456         return pd.DataFrame(dict(zip(columns, data)), index=index)
   4457 

~/.local/lib/python3.7/site-packages/xarray/core/coordinates.py in to_index(self, ordered_dims)
    109             indexes = [self._data.get_index(k) for k in ordered_dims]  # type: ignore
    110             names = list(ordered_dims)
--> 111             return pd.MultiIndex.from_product(indexes, names=names)
    112 
    113     def update(self, other: Mapping[Hashable, Any]) -> None:

/j/office/app/research-python/conda/envs/2019.10/lib/python3.7/site-packages/pandas/core/indexes/multi.py in from_product(cls, iterables, sortorder, names)
    536             iterables = list(iterables)
    537 
--> 538         codes, levels = _factorize_from_iterables(iterables)
    539         codes = cartesian_product(codes)
    540         return MultiIndex(levels, codes, sortorder=sortorder, names=names)

/j/office/app/research-python/conda/envs/2019.10/lib/python3.7/site-packages/pandas/core/arrays/categorical.py in _factorize_from_iterables(iterables)
   2814         # For consistency, it should return a list of 2 lists.
   2815         return [[], []]
-> 2816     return map(list, zip(*(_factorize_from_iterable(it) for it in iterables)))

/j/office/app/research-python/conda/envs/2019.10/lib/python3.7/site-packages/pandas/core/arrays/categorical.py in <genexpr>(.0)
   2814         # For consistency, it should return a list of 2 lists.
   2815         return [[], []]
-> 2816     return map(list, zip(*(_factorize_from_iterable(it) for it in iterables)))

/j/office/app/research-python/conda/envs/2019.10/lib/python3.7/site-packages/pandas/core/arrays/categorical.py in _factorize_from_iterable(values)
   2786         # but only the resulting categories, the order of which is independent
   2787         # from ordered. Set ordered to False as default. See GH #15457
-> 2788         cat = Categorical(values, ordered=False)
   2789         categories = cat.categories
   2790         codes = cat.codes

/j/office/app/research-python/conda/envs/2019.10/lib/python3.7/site-packages/pandas/core/arrays/categorical.py in __init__(self, values, categories, ordered, dtype, fastpath)
    401 
    402             # we're inferring from values
--> 403             dtype = CategoricalDtype(categories, dtype._ordered)
    404 
    405         elif is_categorical_dtype(values):

/j/office/app/research-python/conda/envs/2019.10/lib/python3.7/site-packages/pandas/core/dtypes/dtypes.py in __init__(self, categories, ordered)
    224 
    225     def __init__(self, categories=None, ordered: OrderedType = ordered_sentinel):
--> 226         self._finalize(categories, ordered, fastpath=False)
    227 
    228     @classmethod

/j/office/app/research-python/conda/envs/2019.10/lib/python3.7/site-packages/pandas/core/dtypes/dtypes.py in _finalize(self, categories, ordered, fastpath)
    345 
    346         if categories is not None:
--> 347             categories = self.validate_categories(categories, fastpath=fastpath)
    348 
    349         self._categories = categories

/j/office/app/research-python/conda/envs/2019.10/lib/python3.7/site-packages/pandas/core/dtypes/dtypes.py in validate_categories(categories, fastpath)
    521         if not fastpath:
    522 
--> 523             if categories.hasnans:
    524                 raise ValueError("Categorial categories cannot be null")
    525 

pandas/_libs/properties.pyx in pandas._libs.properties.CachedProperty.__get__()

/j/office/app/research-python/conda/envs/2019.10/lib/python3.7/site-packages/pandas/core/indexes/base.py in hasnans(self)
   1958         """
   1959         if self._can_hold_na:
-> 1960             return bool(self._isnan.any())
   1961         else:
   1962             return False

pandas/_libs/properties.pyx in pandas._libs.properties.CachedProperty.__get__()

/j/office/app/research-python/conda/envs/2019.10/lib/python3.7/site-packages/pandas/core/indexes/base.py in _isnan(self)
   1937         """
   1938         if self._can_hold_na:
-> 1939             return isna(self)
   1940         else:
   1941             # shouldn't reach to this condition by checking hasnans beforehand

/j/office/app/research-python/conda/envs/2019.10/lib/python3.7/site-packages/pandas/core/dtypes/missing.py in isna(obj)
    120     Name: 1, dtype: bool
    121     """
--> 122     return _isna(obj)
    123 
    124 

/j/office/app/research-python/conda/envs/2019.10/lib/python3.7/site-packages/pandas/core/dtypes/missing.py in _isna_new(obj)
    131     # hack (for now) because MI registers as ndarray
    132     elif isinstance(obj, ABCMultiIndex):
--> 133         raise NotImplementedError("isna is not defined for MultiIndex")
    134     elif isinstance(obj, type):
    135         return False

NotImplementedError: isna is not defined for MultiIndex
```