I think it's some lazy calculation that kicks in. Because I can reproduce using np.asarray.

```python
import numpy as np
import xarray as xr

ds = xr.tutorial.load_dataset("air_temperature")
da = ds["air"].stack(z=[...])

coord = da.z.variable.to_index_variable()

# This is very slow:
a = np.asarray(coord)

da._repr_html_()
```
![image](https://user-images.githubusercontent.com/14371165/123465543-8c6fc500-d5ee-11eb-90b3-e814b3411ad4.png)

Yes, I think it's materializing the multiindex as an array of tuples. Which we definitely shouldn't be doing for reprs.

@Illviljan nice profiling view! What is that?
One way of solving it could be to slice the arrays to a smaller size but still showing the same repr. Because `coords[0:12]` seems easy to print, not sure how tricky it is to slice it in this way though.

I'm using https://github.com/spyder-ide/spyder for the profiling and general hacking.
Yes very much so @Illviljan . But weirdly the linked PR is attempting to do that — so maybe this code path doesn't hit that change?

Spyder's profiler looks good! 
> But weirdly the linked PR is attempting to do that — so maybe this code path doesn't hit that change?

I think the linked PR only fixed the summary (inline) repr. The bottleneck here is when formatting the array detailed view for the multi-index coordinates, which triggers the conversion of the whole pandas MultiIndex (tuple elements) and each of its levels as a numpy arrays.