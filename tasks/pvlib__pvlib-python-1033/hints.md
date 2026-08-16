> The `temperature_model_parameters` handling code below suggests to me that in 0.8 we're going to
> 
> 1. set default values `module_type=None` and `racking_model=None`.
> 2. require user to specify either `temperature_model_parameters` or both `module_type` and `racking_model`.
> 
> @cwhanse is that correct?

Yes, that is the intent.

> So I'm guessing that this warning has been seen by only a small fraction of people that need to see it. I'm ok moving forward with the removal in 0.8 or pushing to 0.9.

The warning should have been raised whenever condition #2 above wasn't met; it looks to me that has been the case. If that hasn't been the case I would prefer to fix the warning and push the deprecation out to v0.9. pvlib-python has had that unadvertised default temperature model assignment for a long time.

> The problem is that the only way to see this warning is to supply an invalid `module_type` or `racking_model`. That's because `PVSystem._infer_temperature_model` is called before the code above, and it looks up the default `module_type` and `racking_model` and successfully finds temperature coefficients.

I don't follow here - it looks to me that the warning should be raised if 1) `temperature_model_parameters` isn't specified, or 2) either `module_type` or `racking_model` are invalid. Maybe we're saying the same thing. `_infer_temperature_model` doesn't assign the default temperature model, that is done in the block of code that raises the warning. 


The `module_type` and `racking_model` defaults prevent the warning from showing up in many use cases. If we change the defaults to `None` then the warning will be triggered. If we simultaneously remove the warning then code will break without users having ever seen the warning.
What is the expected behavior for `PVSystem()`?
> The `module_type` and `racking_model` defaults prevent the warning from showing up in many use cases. If we change the defaults to `None` then the warning will be triggered. If we simultaneously remove the warning then code will break without users having ever seen the warning.

Aha. I see the problem now, thanks.  Perhaps remove the defaults in v0.8 and leave the warning until v0.9?
Ok, I'll work on that.
