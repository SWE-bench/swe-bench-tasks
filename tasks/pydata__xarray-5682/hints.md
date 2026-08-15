Note that for simple latex expressions xarray appears to work fine. For example `name = r"$\mathrm{mean}(\epsilon_k)$"` works in both figures in the example above.
I agree this is annoying but there is no good solution AFAIK.

We use textwrap here:
https://github.com/pydata/xarray/blob/8b95da8e21a9d31de9f79cb0506720595f49e1dd/xarray/plot/utils.py#L493

I guess we could skip it if the first character in `name` is `$`?
I'm not entirely sure why that would make the LaTeX renderer fail. But if that's the case and skipping it is an option, I'd test that both the first and last characters are `$` before skipping.
It's the newline join that's the problem. You can get the latex working as textwrap intends by using `"$\n$".join`

```python
import numpy as np
from matplotlib import pyplot as plt
import xarray as xr
da = xr.DataArray(range(5), dims="x", coords = dict(x=range(5)))
name = r"$Ra_s = \mathrm{mean}(\epsilon_k) / \mu M^2_\infty$"
name = "$\n$".join(textwrap.wrap(name, 30))
da.x.attrs = dict(long_name = name)
da.plot()

plt.figure()
plt.plot(range(5))
plt.xlabel(name)
```
But that looks worse than the original, checking if the string is latex-able seems a good idea.