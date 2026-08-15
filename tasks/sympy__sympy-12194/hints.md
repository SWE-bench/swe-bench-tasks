A possibility is:

```
>>> from sympy.utilities.iterables import multiset_combinations
>>> d={'a':3,'b':2,'c':2}
>>> list(multiset_combinations(d, sum(d.values())))[0]
['a', 'a', 'a', 'b', 'b', 'c', 'c']
>>> d = factoring(24)
>>> list(multiset_combinations(d, sum(d.values())))[0]
[2, 2, 2, 3]
```

But maybe an argument `multiple=True` for `factorint` would be preferable.
@smichr `multiple=True`  for `factorint` is definitely better than my suggestion. I really do think that providing this functionality straight up without a helper function is an improvement for sympy.