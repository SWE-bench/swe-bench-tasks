expand PVSystem repr
The PVSystem repr is

https://github.com/pvlib/pvlib-python/blob/27872b83b0932cc419116f79e442963cced935bb/pvlib/pvsystem.py#L239-L243

The main issue that I have is that the repr doesn't give me enough information about the temperature model settings. It's relatively important because `temperature_model_params` (not printed) may be inferred from `module_type` (not printed) and `racking_model` (printed). So I'd like to add both `temperature_model_params` and `module_type`.

We also don't include `module_parameters`, `inverter_parameters`, and `losses_parameters` in the repr. If I recall correctly, we decided against including these because they can be relatively long. I still think that's reasonable. We could add something like `if len(module_parameters): 'Set. See PVSystem.module_parameters'; else: {}`, but I don't know if that's worth the effort.
