Hmm, this is a little puzzling. I'll mark this as a bug.
Could be the same reason as #4543: `pd.Index(["a", "b"])` has `dtype=object`
I think the problem is in `align` and that `pd.Index(["a"])` has `dtype=object`:

```python
import pandas as pd
pd.Index(["a", "b"])
```

`concat` calls `align` here

https://github.com/pydata/xarray/blob/adc55ac4d2883e0c6647f3983c3322ca2c690514/xarray/core/concat.py#L383

and align basically does the following:

```python
index = da1.indexes["x2"] | da2.indexes["x2"]
da1.reindex({"x2": index})
```

Thus we replace the coords with an index.






