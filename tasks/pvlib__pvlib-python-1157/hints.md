Confirmed. This is a bug in `pvlib.modelchain.ModelChain._prepare_temperature` not all inputs are tuples and aren't being converted. @wfvining fyi and lmk if you want to fix it.
Definitely a bug, but I think the correct behavior is slightly different than you expect. Because you pass a list to `ModelChain.run_model()` the output should be a tuple with a single `pd.Series` element.
I agree that passing data as a tuple/list should result in all results being tuples of Series/DataFrames. So perhaps this is a separate bug, but ``array_run.results.total_irrad`` (and other results properties) is a singular `pd.DataFrame` instead of `Tuple[pd.DataFrame]`. 
Yes, that's the problem. We should make those match the type of `ModelChain.weather`. Not sure about this, but we might be able to pass ~`unwrap=isinstance(self.weather, tuple)`~ `unwrap=not isinstance(self.weather, tuple)` to the `PVSystem` methods to accomplish this. Probably won't be that easy though, since `ModelChain` interacts heavily with `PVSystem` attributes like `temperature_model_params` which can't accept that kwarg.
Perhaps a related error is raised when running 
```python
poa_data = pd.DataFrame(
    {
        "poa_global": [1100.0, 1101.0],
        "poa_direct": [1000.0, 1001],
        "poa_diffuse": [100.0, 100],
        "module_temperature": [25.0, 25],
    },
    index=pd.DatetimeIndex(
        [pd.Timestamp("2021-01-20T12:00-05:00"), pd.Timestamp("2021-01-20T12:05-05:00")]
    ),
)

ModelChain(
    array_sys, location, aoi_model="no_loss", spectral_model="no_loss",
).run_model_from_poa([poa_data]) 
```
raises a TypeError here https://github.com/pvlib/pvlib-python/blob/6b92d218653633e366241c31e8836c0072739ece/pvlib/modelchain.py#L1102-L1106
because `self.results.aoi_modifier = 1.0` and `self.results.spectral_modifier = 1.0` 
https://github.com/pvlib/pvlib-python/blob/6b92d218653633e366241c31e8836c0072739ece/pvlib/modelchain.py#L904-L909
Yup, that's the *first* place this error creeps in. That needs to change, as well as the methods that apply loss models from `PVSystem`.  `ModelChain._prep_inputs_fixed()` also needs updating, as well as `_prepate_temperature` itself. I suspect there are one or two other places as well.

I'm kicking myself a bit for not considering this corner case initially. Very glad you found it early on.
One simple solution might be to add some indirection when assigning to `ModelChain.results`. Instead of assigning directly, assignments go through an `_assign_result(field, value)` method that ensures the type of `value` matches `ModelChain.weather`. This might not be the *best* option, but it would not be too difficult to implement.