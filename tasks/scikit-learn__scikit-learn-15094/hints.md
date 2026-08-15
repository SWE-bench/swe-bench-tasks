It should probably be preserving dtype. It doesn't look like this issue
should result from check_array, which looks like it is set up to preserve
dtype in MaxAbsScaler.

Can you please confirm that this is still an issue in scikit-learn 0.21
(you have an old version)?

Thanks for the quick response! 
Same issue with 0.21.3

```
Darwin-18.7.0-x86_64-i386-64bit
Python 3.6.7 | packaged by conda-forge | (default, Jul  2 2019, 02:07:37) 
[GCC 4.2.1 Compatible Clang 4.0.1 (tags/RELEASE_401/final)]
NumPy 1.17.1
SciPy 1.3.1
Scikit-Learn 0.21.3
Pandas 0.25.1
```

Upon a closer look, this might be a bug in check_array, though I don't know enough about its desired functionality to comment. `MaxAbsScaler` calls `check_array` with `dtype=FLOAT_DTYPES` which has the value`['float64', 'float32', 'float16']`. In `check_array`,  pandas dtypes are properly pulled but not used. Instead, `check_array` pulls the dtype from first list item in the supplied `dtype=FLOAT_DTYPES`, which results in 'float64'. I placed inline comments next to what I think is going on:

```python
dtypes_orig = None
if hasattr(array, "dtypes") and hasattr(array.dtypes, '__array__'):
    dtypes_orig = np.array(array.dtypes) # correctly pulls the float32 dtypes from pandas

if dtype_numeric:
    if dtype_orig is not None and dtype_orig.kind == "O":
        # if input is object, convert to float.
        dtype = np.float64
    else:
        dtype = None

if isinstance(dtype, (list, tuple)):
    if dtype_orig is not None and dtype_orig in dtype:
        # no dtype conversion required
        dtype = None
    else:
        # dtype conversion required. Let's select the first element of the
        # list of accepted types.
        dtype = dtype[0] # Should this be dtype = dtypes_orig[0]? dtype[0] is always float64
```
Thanks again!
It shouldn't be going down that path... It should be using the "no dtype
conversion required" path

Can confirm it's a bug in the handling of pandas introduced here: #10949
If dtypes has more then one entry we need to figure out the best cast, right?
Here we're in the simple case where ``len(unique(dtypes)))==1`` which is easy to fix.