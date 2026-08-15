For reference, here's the traceback:
```
---------------------------------------------------------------------------
ValueError                                Traceback (most recent call last)
<ipython-input-11-fcbc1dfa5ae4> in <module>()
----> 1 print(D2.loc[dict(dim1='x', method='a')])  # does not work!!

/usr/local/lib/python3.6/dist-packages/xarray/core/dataarray.py in __getitem__(self, key)
    104             labels = indexing.expanded_indexer(key, self.data_array.ndim)
    105             key = dict(zip(self.data_array.dims, labels))
--> 106         return self.data_array.sel(**key)
    107 
    108     def __setitem__(self, key, value):

/usr/local/lib/python3.6/dist-packages/xarray/core/dataarray.py in sel(self, indexers, method, tolerance, drop, **indexers_kwargs)
    847         ds = self._to_temp_dataset().sel(
    848             indexers=indexers, drop=drop, method=method, tolerance=tolerance,
--> 849             **indexers_kwargs)
    850         return self._from_temp_dataset(ds)
    851 

/usr/local/lib/python3.6/dist-packages/xarray/core/dataset.py in sel(self, indexers, method, tolerance, drop, **indexers_kwargs)
   1608         indexers = either_dict_or_kwargs(indexers, indexers_kwargs, 'sel')
   1609         pos_indexers, new_indexes = remap_label_indexers(
-> 1610             self, indexers=indexers, method=method, tolerance=tolerance)
   1611         result = self.isel(indexers=pos_indexers, drop=drop)
   1612         return result._replace_indexes(new_indexes)

/usr/local/lib/python3.6/dist-packages/xarray/core/coordinates.py in remap_label_indexers(obj, indexers, method, tolerance, **indexers_kwargs)
    353 
    354     pos_indexers, new_indexes = indexing.remap_label_indexers(
--> 355         obj, v_indexers, method=method, tolerance=tolerance
    356     )
    357     # attach indexer's coordinate to pos_indexers

/usr/local/lib/python3.6/dist-packages/xarray/core/indexing.py in remap_label_indexers(data_obj, indexers, method, tolerance)
    256         else:
    257             idxr, new_idx = convert_label_indexer(index, label,
--> 258                                                   dim, method, tolerance)
    259             pos_indexers[dim] = idxr
    260             if new_idx is not None:

/usr/local/lib/python3.6/dist-packages/xarray/core/indexing.py in convert_label_indexer(index, label, index_name, method, tolerance)
    185                 indexer, new_index = index.get_loc_level(label.item(), level=0)
    186             else:
--> 187                 indexer = get_loc(index, label.item(), method, tolerance)
    188         elif label.dtype.kind == 'b':
    189             indexer = label

/usr/local/lib/python3.6/dist-packages/xarray/core/indexing.py in get_loc(index, label, method, tolerance)
    112 def get_loc(index, label, method=None, tolerance=None):
    113     kwargs = _index_method_kwargs(method, tolerance)
--> 114     return index.get_loc(label, **kwargs)
    115 
    116 

/usr/local/lib/python3.6/dist-packages/pandas/core/indexes/base.py in get_loc(self, key, method, tolerance)
   2527                 return self._engine.get_loc(self._maybe_cast_indexer(key))
   2528 
-> 2529         indexer = self.get_indexer([key], method=method, tolerance=tolerance)
   2530         if indexer.ndim > 1 or indexer.size > 1:
   2531             raise TypeError('get_loc requires scalar valued input')

/usr/local/lib/python3.6/dist-packages/pandas/core/indexes/base.py in get_indexer(self, target, method, limit, tolerance)
   2662     @Appender(_index_shared_docs['get_indexer'] % _index_doc_kwargs)
   2663     def get_indexer(self, target, method=None, limit=None, tolerance=None):
-> 2664         method = missing.clean_reindex_fill_method(method)
   2665         target = _ensure_index(target)
   2666         if tolerance is not None:

/usr/local/lib/python3.6/dist-packages/pandas/core/missing.py in clean_reindex_fill_method(method)
    589 
    590 def clean_reindex_fill_method(method):
--> 591     return clean_fill_method(method, allow_nearest=True)
    592 
    593 

/usr/local/lib/python3.6/dist-packages/pandas/core/missing.py in clean_fill_method(method, allow_nearest)
     91         msg = ('Invalid fill method. Expecting {expecting}. Got {method}'
     92                .format(expecting=expecting, method=method))
---> 93         raise ValueError(msg)
     94     return method
     95 

ValueError: Invalid fill method. Expecting pad (ffill), backfill (bfill) or nearest. Got a
```
I think this could be fixed simply by replacing `self.data_array.sel(**key)` with `self.data_array.sel(key)` on this line in `_LocIndexer.__getitem__`:
https://github.com/pydata/xarray/blob/742ed3984f437982057fd46ecfb0bce214563cb8/xarray/core/dataarray.py#L103
For reference, here's the traceback:
```
---------------------------------------------------------------------------
ValueError                                Traceback (most recent call last)
<ipython-input-11-fcbc1dfa5ae4> in <module>()
----> 1 print(D2.loc[dict(dim1='x', method='a')])  # does not work!!

/usr/local/lib/python3.6/dist-packages/xarray/core/dataarray.py in __getitem__(self, key)
    104             labels = indexing.expanded_indexer(key, self.data_array.ndim)
    105             key = dict(zip(self.data_array.dims, labels))
--> 106         return self.data_array.sel(**key)
    107 
    108     def __setitem__(self, key, value):

/usr/local/lib/python3.6/dist-packages/xarray/core/dataarray.py in sel(self, indexers, method, tolerance, drop, **indexers_kwargs)
    847         ds = self._to_temp_dataset().sel(
    848             indexers=indexers, drop=drop, method=method, tolerance=tolerance,
--> 849             **indexers_kwargs)
    850         return self._from_temp_dataset(ds)
    851 

/usr/local/lib/python3.6/dist-packages/xarray/core/dataset.py in sel(self, indexers, method, tolerance, drop, **indexers_kwargs)
   1608         indexers = either_dict_or_kwargs(indexers, indexers_kwargs, 'sel')
   1609         pos_indexers, new_indexes = remap_label_indexers(
-> 1610             self, indexers=indexers, method=method, tolerance=tolerance)
   1611         result = self.isel(indexers=pos_indexers, drop=drop)
   1612         return result._replace_indexes(new_indexes)

/usr/local/lib/python3.6/dist-packages/xarray/core/coordinates.py in remap_label_indexers(obj, indexers, method, tolerance, **indexers_kwargs)
    353 
    354     pos_indexers, new_indexes = indexing.remap_label_indexers(
--> 355         obj, v_indexers, method=method, tolerance=tolerance
    356     )
    357     # attach indexer's coordinate to pos_indexers

/usr/local/lib/python3.6/dist-packages/xarray/core/indexing.py in remap_label_indexers(data_obj, indexers, method, tolerance)
    256         else:
    257             idxr, new_idx = convert_label_indexer(index, label,
--> 258                                                   dim, method, tolerance)
    259             pos_indexers[dim] = idxr
    260             if new_idx is not None:

/usr/local/lib/python3.6/dist-packages/xarray/core/indexing.py in convert_label_indexer(index, label, index_name, method, tolerance)
    185                 indexer, new_index = index.get_loc_level(label.item(), level=0)
    186             else:
--> 187                 indexer = get_loc(index, label.item(), method, tolerance)
    188         elif label.dtype.kind == 'b':
    189             indexer = label

/usr/local/lib/python3.6/dist-packages/xarray/core/indexing.py in get_loc(index, label, method, tolerance)
    112 def get_loc(index, label, method=None, tolerance=None):
    113     kwargs = _index_method_kwargs(method, tolerance)
--> 114     return index.get_loc(label, **kwargs)
    115 
    116 

/usr/local/lib/python3.6/dist-packages/pandas/core/indexes/base.py in get_loc(self, key, method, tolerance)
   2527                 return self._engine.get_loc(self._maybe_cast_indexer(key))
   2528 
-> 2529         indexer = self.get_indexer([key], method=method, tolerance=tolerance)
   2530         if indexer.ndim > 1 or indexer.size > 1:
   2531             raise TypeError('get_loc requires scalar valued input')

/usr/local/lib/python3.6/dist-packages/pandas/core/indexes/base.py in get_indexer(self, target, method, limit, tolerance)
   2662     @Appender(_index_shared_docs['get_indexer'] % _index_doc_kwargs)
   2663     def get_indexer(self, target, method=None, limit=None, tolerance=None):
-> 2664         method = missing.clean_reindex_fill_method(method)
   2665         target = _ensure_index(target)
   2666         if tolerance is not None:

/usr/local/lib/python3.6/dist-packages/pandas/core/missing.py in clean_reindex_fill_method(method)
    589 
    590 def clean_reindex_fill_method(method):
--> 591     return clean_fill_method(method, allow_nearest=True)
    592 
    593 

/usr/local/lib/python3.6/dist-packages/pandas/core/missing.py in clean_fill_method(method, allow_nearest)
     91         msg = ('Invalid fill method. Expecting {expecting}. Got {method}'
     92                .format(expecting=expecting, method=method))
---> 93         raise ValueError(msg)
     94     return method
     95 

ValueError: Invalid fill method. Expecting pad (ffill), backfill (bfill) or nearest. Got a
```
I think this could be fixed simply by replacing `self.data_array.sel(**key)` with `self.data_array.sel(key)` on this line in `_LocIndexer.__getitem__`:
https://github.com/pydata/xarray/blob/742ed3984f437982057fd46ecfb0bce214563cb8/xarray/core/dataarray.py#L103