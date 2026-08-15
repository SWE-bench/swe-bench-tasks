Thanks for the clear report. Indeed, this looks like a bug.

`bfill()` and `ffill()` are implemented on dask arrays via `apply_ufunc`, but they're applied independently on each chunk -- there's no filling between chunks:
https://github.com/pydata/xarray/blob/ddacf405fb256714ce01e1c4c464f829e1cc5058/xarray/core/missing.py#L262-L289

Instead, I think we need a multi-step process for parallelizing `bottleneck.push`, e.g.,
1. Forward fill each chunk independently.
2. Slice out the *last element* of each chunk and forward fill these.
3. Prepend filled last elements to the start of each chunk, and forward fill them again.
I think this will work (though it needs more tests):
```python
import bottleneck
import dask.array as da
import numpy as np

def _last_element(array, axis):
  slices = [slice(None)] * array.ndim
  slices[axis] = slice(-1, None)
  return array[tuple(slices)]

def _concat_push_slice(last_elements, array, axis):
  concatenated = np.concatenate([last_elements, array], axis=axis)
  pushed = bottleneck.push(concatenated, axis=axis)
  slices = [slice(None)] * array.ndim
  slices[axis] = slice(1, None)
  sliced = pushed[tuple(slices)]
  return sliced

def push(array, axis):
  if axis < 0:
    axis += array.ndim
  pushed = array.map_blocks(bottleneck.push, dtype=array.dtype, axis=axis)
  new_chunks = list(array.chunks)
  new_chunks[axis] = tuple(1 for _ in array.chunks[axis])
  last_elements = pushed.map_blocks(
      _last_element, dtype=array.dtype, chunks=tuple(new_chunks), axis=axis)
  pushed_last_elements = (
      last_elements.rechunk({axis: -1})
      .map_blocks(bottleneck.push, dtype=array.dtype, axis=axis)
      .rechunk({axis: 1})
  )
  nan_shape = tuple(1 if axis == a else s for a, s in enumerate(array.shape))
  nan_chunks = tuple((1,) if axis == a else c for a, c in enumerate(array.chunks))
  shifted_pushed_last_elements = da.concatenate(
      [da.full(np.nan, shape=nan_shape, chunks=nan_chunks),
       pushed_last_elements[(slice(None),) * axis + (slice(None, -1),)]],
      axis=axis)
  return da.map_blocks(
      _concat_push_slice,
      shifted_pushed_last_elements,
      pushed,
      dtype=array.dtype,
      chunks=array.chunks,
      axis=axis,
  )

# tests
array = np.array([np.nan, np.nan, np.nan, 1, 2, 3,
                  np.nan, np.nan, 4, 5, np.nan, 6])
expected = bottleneck.push(array, axis=0)
for c in range(1, 11):
  actual = push(da.from_array(array, chunks=c), axis=0).compute()
  np.testing.assert_equal(actual, expected)
```
I also recently encountered this bug and without user warnings it took me a while to identify its origin. I'll use this temporary fix. Thanks
I encountered this bug a few days ago.
I understand it isn't trivial to fix, but would it be possible to check and throw an exception? Still better than having it go unnoticed. Thanks