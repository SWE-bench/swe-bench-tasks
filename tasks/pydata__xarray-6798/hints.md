I agree a depreciation warning is a bit nicer than an error message for this specific case.

If we agree on eventually removing the pandas multi-index dimension coordinate, perhaps this issue should be addressed in that wider context as it will be directly impacted? It would make our plans clear to users if we issue a depreciation warning message that already mentions this future removal (and that we could also issue now or later in other places like `sel`).
Here's another version of the same bug affecting `Dataset.assign)
``` python
import xarray

array = xarray.DataArray(
    [[1, 2], [3, 4]],
    dims=['x', 'y'],
    coords={'x': ['a', 'b']},
)
stacked = array.stack(z=['x', 'y']).to_dataset(name="a")
stacked.assign_coords(f1=2*stacked.a)  # works
stacked.assign(f2=2*stacked.a)  # error
```

<details>
```
---------------------------------------------------------------------------
ValueError                                Traceback (most recent call last)
Input In [33], in <cell line: 10>()
      8 stacked = array.stack(z=['x', 'y']).to_dataset(name="a")
      9 stacked.assign_coords(f1=2*stacked.a)
---> 10 stacked.assign(f2=2*stacked.a)

File ~/work/python/xarray/xarray/core/dataset.py:5444, in Dataset.assign(self, variables, **variables_kwargs)
   5442 results = data._calc_assign_results(variables)
   5443 # ... and then assign
-> 5444 data.update(results)
   5445 return data

File ~/work/python/xarray/xarray/core/dataset.py:4421, in Dataset.update(self, other)
   4385 def update(self, other: CoercibleMapping) -> Dataset:
   4386     """Update this dataset's variables with those from another dataset.
   4387 
   4388     Just like :py:meth:`dict.update` this is a in-place operation.
   (...)
   4419     Dataset.merge
   4420     """
-> 4421     merge_result = dataset_update_method(self, other)
   4422     return self._replace(inplace=True, **merge_result._asdict())

File ~/work/python/xarray/xarray/core/merge.py:1068, in dataset_update_method(dataset, other)
   1062             coord_names = [
   1063                 c
   1064                 for c in value.coords
   1065                 if c not in value.dims and c in dataset.coords
   1066             ]
   1067             if coord_names:
-> 1068                 other[key] = value.drop_vars(coord_names)
   1070 return merge_core(
   1071     [dataset, other],
   1072     priority_arg=1,
   1073     indexes=dataset.xindexes,
   1074     combine_attrs="override",
   1075 )

File ~/work/python/xarray/xarray/core/dataarray.py:2406, in DataArray.drop_vars(self, names, errors)
   2387 def drop_vars(
   2388     self, names: Hashable | Iterable[Hashable], *, errors: str = "raise"
   2389 ) -> DataArray:
   2390     """Returns an array with dropped variables.
   2391 
   2392     Parameters
   (...)
   2404         New Dataset copied from `self` with variables removed.
   2405     """
-> 2406     ds = self._to_temp_dataset().drop_vars(names, errors=errors)
   2407     return self._from_temp_dataset(ds)

File ~/work/python/xarray/xarray/core/dataset.py:4549, in Dataset.drop_vars(self, names, errors)
   4546 if errors == "raise":
   4547     self._assert_all_in_dataset(names)
-> 4549 assert_no_index_corrupted(self.xindexes, names)
   4551 variables = {k: v for k, v in self._variables.items() if k not in names}
   4552 coord_names = {k for k in self._coord_names if k in variables}

File ~/work/python/xarray/xarray/core/indexes.py:1394, in assert_no_index_corrupted(indexes, coord_names)
   1392 common_names_str = ", ".join(f"{k!r}" for k in common_names)
   1393 index_names_str = ", ".join(f"{k!r}" for k in index_coords)
-> 1394 raise ValueError(
   1395     f"cannot remove coordinate(s) {common_names_str}, which would corrupt "
   1396     f"the following index built from coordinates {index_names_str}:\n"
   1397     f"{index}"
   1398 )

ValueError: cannot remove coordinate(s) 'y', 'x', which would corrupt the following index built from coordinates 'z', 'x', 'y':
<xarray.core.indexes.PandasMultiIndex object at 0x16d3a6430>
```
</details>
Reopening because my second example `print(stacked.assign_coords(z=[1, 2, 3, 4]))` is still broken with the same error message. It would be ideal to fix this before the release.