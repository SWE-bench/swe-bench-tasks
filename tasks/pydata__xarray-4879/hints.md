Thanks for the clear example!

This happens dues to xarray's caching logic for files: 
https://github.com/pydata/xarray/blob/b1c7e315e8a18e86c5751a0aa9024d41a42ca5e8/xarray/backends/file_manager.py#L50-L76

This means that when you open the same filename, xarray doesn't actually reopen the file from disk -- instead it points to the same file object already cached in memory.

I can see why this could be confusing. We do need this caching logic for files opened from the same `backends.*DataStore` class, but this could include some sort of unique identifier (i.e., from `uuid`) to ensure each separate call to `xr.open_dataset` results in a separately cached/opened file object: 
https://github.com/pydata/xarray/blob/b1c7e315e8a18e86c5751a0aa9024d41a42ca5e8/xarray/backends/netCDF4_.py#L355-L357
is there a workaround for forcing the opening without restarting the notebook?
now i'm wondering why the caching logic is only activated by the `repr`? As you can see, when printed, it always updated to the status on disk?
Probably the easiest work around is to call `.close()` on the original dataset. Failing that, the file is cached in `xarray.backends.file_manager.FILE_CACHE`, which you could muck around with.

I believe it only gets activated by `repr()` because array values from netCDF file are loaded lazily. Not 100% without more testing, though.
Would it be an option to consider the time stamp of the file's last change as a caching criterion?
I've stumbled over this weird behaviour many times and was wondering why this happens. So AFAICT @shoyer hit the nail on the head but the root cause is that the Dataset is added to the notebook namespace somehow, if one just evaluates it in the cell.

This doesn't happen if you invoke the `__repr__` via

```python
display(xr.open_dataset("saved_on_disk.nc"))
```

I've forced myself to use either `print` or `display` for xarray data. As this also happens if the Dataset is attached to a variable you would need to specifically delete (or .close()) the variable in question before opening again. 

```python
try: 
    del ds
except NameError:
    pass
ds = xr.open_dataset("saved_on_disk.nc")
```
