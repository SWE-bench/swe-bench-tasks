Unfortunately this is a pandas thing, so we can't fix it. Pandas only provides `Int64Index` so everything gets cast to that. Fixing that is on the roadmap for pandas 2.0 I think (See https://github.com/pandas-dev/pandas/pull/44819#issuecomment-999790361)
Darn. Well, to help this be more transparent, I think it would be on XArray to sync the new `dtype` in the variable's attributes. Because I also currently get `False` for the following:

```
ds.stack(b=('a',))['a'].dtype == ds.stack(b=('a',))['a'].values.dtype
```

Thanks for looking into this issue!
Ah very good find! Thanks.

 maybe this can be fixed, or at least made more consistent. I think `.values` is pulling out of the pandas index (so is promoted) while we do actually have an underlying `int32` array.

``` python
>>> ds.stack(b=('a',))['a'].dtype #== ds.stack(b=('a',))['a'].values.dtype
dtype('int32')

>>> ds.stack(b=('a',))['a'].values.dtype
dtype('int64')
```


cc @benbovy 
You're welcome! Please let me know if a PR (a first for me on xarray) would be welcome. A pointer to the relevant source would get me started.
That's a bug in this method: https://github.com/pydata/xarray/blob/6f9e33e94944f247a5c5c5962a865ff98a654b30/xarray/core/indexing.py#L1528-L1532

Xarray array wrappers for pandas indexes keep track of the original dtype and should restore it when converted into numpy arrays. Something like this should work for the same method:

```python
    def __array__(self, dtype: DTypeLike = None) -> np.ndarray:
        if dtype is None:
            dtype = self.dtype
        if self.level is not None:
            return np.asarray(
                self.array.get_level_values(self.level).values, dtype=dtype
            )
        else:
            return super().__array__(dtype)
```