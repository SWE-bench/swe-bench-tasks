I don't think this is intentional and we are happy to take a PR. The problem seems to be here:

https://github.com/pydata/xarray/blob/c7c4aae1fa2bcb9417e498e7dcb4acc0792c402d/xarray/core/groupby.py#L439

You will also have to fix the tests (maybe other places):

https://github.com/pydata/xarray/blob/c7c4aae1fa2bcb9417e498e7dcb4acc0792c402d/xarray/tests/test_groupby.py#L391
https://github.com/pydata/xarray/blob/c7c4aae1fa2bcb9417e498e7dcb4acc0792c402d/xarray/tests/test_groupby.py#L408
