👍🏽 on adding a configurable option to the list of options supported via `xr.set_options()`

```python
import xarray as xr
xr.set_options(display_max_num_variables=25)
```


Yes, this sounds like a welcome new feature! As a general rule, the output of repr() should fit on one screen.