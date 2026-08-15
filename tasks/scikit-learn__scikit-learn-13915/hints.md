Proposed fix:
Add 
```python
if mat.indptr.dtype == np.int64:
        mat.indptr = mat.indptr.astype('int32')
```
below `mat = X.tocsc() if axis == 0 else X.tocsr()` in `utils.sparsefuncs._min_or_max_axis`.

When `tocsc` is called for a csr matrix with indptr dtype int64, it returns a csc matrix with indptr dtype int32, but when it's called for a csc matrix that conversion doesn't happen (I assume the original matrix is returned). It's the lack of this conversion that causes the error, and it seems logical to fix it at this point.
Proposed fixes are best shared by opening a pull request.

But downcasting the indices dtype when your matrix is too big to fit into
int32 is not a valid solution, even if it will pass the current tests.

Sure; this is a tentative suggestion. Looking into it a bit more I agree it's wrong, but downcasting is still necessary.

The problem here is that there are two kinds of casting going on. The `ufunc.reduceat` line casts `X.indptr` to `np.intp` using numpy safety rules, where casting _any_ value from 64 bits to 32 is unsafe. But when the input is a csr matrix, the line `mat = X.tocsc()` is willing to cast `X.indptr` from 64 bits to 32 provided that the values in it all fit in an int32. Since `X.tocsc()` doesn't do anything when `X` is already a csc matrix, we don't get this more precise behaviour. Doing `astype('int32')` as I originally suggested wouldn't give it either; I think the easiest way to get it is to add `mat = type(mat)((mat.data, mat.indices, mat.indptr), shape=mat.shape)` after `mat = X.tocsc() if axis == 0 else X.tocsr()`. The `reduceat` line will still give an error on 32 bit systems if there are values in `X.indptr` that don't fit into an int32, but I think that's what should happen (and what does happen now with large csr matrices).