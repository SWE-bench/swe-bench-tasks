Hi @lukasbindreiter, could you add the whole error traceback please?
I can see this type of decoding breaking some assumption in the file reading process. A full traceback would help identify where.

I think the real solution is actually #4490, so you could explicitly provide a coder.
Here is the full stacktrace:

```python
---------------------------------------------------------------------------
ValueError                                Traceback (most recent call last)
Cell In [12], line 7
----> 7 loaded = xr.open_dataset("multiindex.nc", engine="netcdf4-multiindex", handle_multiindex=True)
      8 print(loaded)

File ~/.local/share/virtualenvs/test-oePfdNug/lib/python3.8/site-packages/xarray/backends/api.py:537, in open_dataset(filename_or_obj, engine, chunks, cache, decode_cf, mask_and_scale, decode_times, decode_timedelta, use_cftime, concat_characters, decode_coords, drop_variables, inline_array, backend_kwargs, **kwargs)
    530 overwrite_encoded_chunks = kwargs.pop("overwrite_encoded_chunks", None)
    531 backend_ds = backend.open_dataset(
    532     filename_or_obj,
    533     drop_variables=drop_variables,
    534     **decoders,
    535     **kwargs,
    536 )
--> 537 ds = _dataset_from_backend_dataset(
    538     backend_ds,
    539     filename_or_obj,
    540     engine,
    541     chunks,
    542     cache,
    543     overwrite_encoded_chunks,
    544     inline_array,
    545     drop_variables=drop_variables,
    546     **decoders,
    547     **kwargs,
    548 )
    549 return ds

File ~/.local/share/virtualenvs/test-oePfdNug/lib/python3.8/site-packages/xarray/backends/api.py:345, in _dataset_from_backend_dataset(backend_ds, filename_or_obj, engine, chunks, cache, overwrite_encoded_chunks, inline_array, **extra_tokens)
    340 if not isinstance(chunks, (int, dict)) and chunks not in {None, "auto"}:
    341     raise ValueError(
    342         f"chunks must be an int, dict, 'auto', or None. Instead found {chunks}."
    343     )
--> 345 _protect_dataset_variables_inplace(backend_ds, cache)
    346 if chunks is None:
    347     ds = backend_ds

File ~/.local/share/virtualenvs/test-oePfdNug/lib/python3.8/site-packages/xarray/backends/api.py:239, in _protect_dataset_variables_inplace(dataset, cache)
    237 if cache:
    238     data = indexing.MemoryCachedArray(data)
--> 239 variable.data = data

File ~/.local/share/virtualenvs/test-oePfdNug/lib/python3.8/site-packages/xarray/core/variable.py:2795, in IndexVariable.data(self, data)
   2793 @Variable.data.setter  # type: ignore[attr-defined]
   2794 def data(self, data):
-> 2795     raise ValueError(
   2796         f"Cannot assign to the .data attribute of dimension coordinate a.k.a IndexVariable {self.name!r}. "
   2797         f"Please use DataArray.assign_coords, Dataset.assign_coords or Dataset.assign as appropriate."
   2798     )

ValueError: Cannot assign to the .data attribute of dimension coordinate a.k.a IndexVariable 'measurement'. Please use DataArray.assign_coords, Dataset.assign_coords or Dataset.assign as appropriate.
```
Looks like the backend logic needs some updates to make it compatible with the new xarray data model with explicit indexes (i.e., possible indexed coordinates with name != dimension like for multi-index levels now), e.g., here:

https://github.com/pydata/xarray/blob/8eea8bb67bad0b5ac367c082125dd2b2519d4f52/xarray/backends/api.py#L234-L241

