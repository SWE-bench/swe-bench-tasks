PVSystem.temperature_model_parameters requirement
The `temperature_model_parameters` handling code below suggests to me that in 0.8 we're going to 

1. set default values `module_type=None` and `racking_model=None`.
2. require user to specify either `temperature_model_parameters` or both `module_type` and `racking_model`.

https://github.com/pvlib/pvlib-python/blob/27872b83b0932cc419116f79e442963cced935bb/pvlib/pvsystem.py#L208-L221

@cwhanse is that correct?

The problem is that the only way to see this warning is to supply an invalid `module_type` or `racking_model`. That's because `PVSystem._infer_temperature_model` is called before the code above, and it looks up the default `module_type` and `racking_model` and successfully finds temperature coefficients.

https://github.com/pvlib/pvlib-python/blob/27872b83b0932cc419116f79e442963cced935bb/pvlib/pvsystem.py#L201-L203

So I'm guessing that this warning has been seen by only a small fraction of people that need to see it. I'm ok moving forward with the removal in 0.8 or pushing to 0.9. 
remove deprecated functions in 0.8
`pvsystem`:
* `sapm_celltemp`
* `pvsyst_celltemp`
* `ashraeiam`
* `physicaliam`
* `sapm_aoi_loss`
* `PVSystem.ashraeiam`
* `PVSystem.physicaliam`
* `PVSystem.sapm_aoi_loss`
* inference of `PVSystem.temperature_model_parameters`

`modelchain.ModelChain`:
* remove `times` from `complete_irradiance`, `prepare_inputs`, `run_model`
* remove `temp_model` kwarg
