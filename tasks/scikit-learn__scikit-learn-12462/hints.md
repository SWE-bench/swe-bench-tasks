Some context: dask DataFrame doesn't know it's length. Previously, it didn't have a `shape` attribute.

Now dask DataFrame has a shape that returns a `Tuple[Delayed, int]` for the number of rows and columns.

> Work-around shown below, but it's not ideal because it requires me to cast from Dask Arrays to numpy arrays which won't work if the data is huge.

FYI @ZWMiller that's exactly what was occurring previously. Personally, I don't think relying on this is a good idea, for exactly the reason you state.

In `_num_samples` scikit-learn simply checks whether the array-like has a `'shape'` attribute, and then assumes that it's an int from there on. The potential fix would be slightly stricter duck typing. Checking something like `hasattr(x, 'shape') and isinstance(x.shape[0], int)` or `numbers.Integral`.

```python
if hasattr(x, 'shape') and isinstance(x.shape[0], int):
    ...
else:
    return len(x) 
```