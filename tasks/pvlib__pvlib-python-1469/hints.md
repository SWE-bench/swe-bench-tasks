I think I agree that it would make more sense to pass around ground albedo with the weather data instead of treating it as a characteristic of the array.  

> Albedo is treated as a scalar constant in pvlib

> An alternative we have implemented is calling ModelChain.run_model() on each row of a dataframe and manually updating the albedo of the array in each tilmestep. 

It is true that the docs for `Array` and `PVSystem` say that `albedo` is a float, but I think it also works to set albedo to a time series that matches the weather you pass to `ModelChain.run_model()`.  At least that saves you from looping w/ scalar albedo values.  
I agree that albedo can change with e.g., precipitation or season, but it is also a property of the bare ground surface, and it is that perspective that put albedo with the system parameters. One use case for not having albedo in the weather data would be to evaluate the effect of different ground cover on array output.

I am only away of the NSRDB offering albedo with weather data; are there other sources?

I'm +1 on allowing `albedo` to be a Series. I'm neutral on bundling albedo with weather data, but I don't see a better option.  We only have two data structures that supply `ModelChain`: the `weather` DataFrame, and the `PVSystem` instance. I don't think it is practical to create a third just for `albedo`, and it isn't any more work to add or modify `albedo` to `weather` than it is to extract `albedo` from downloaded weather data and add it to `PVSystem`.


To clarify my above message, I think it *already* works to set `PVSystem.albedo` or `Array.albedo` to a Series, despite the docs saying it must be float.  

> are there other sources?

A non-exhaustive list of examples: [SolarAnywhere](https://www.solaranywhere.com/support/data-fields/albedo/), [SolarGIS](https://solargis.com/docs/getting-started/data-parameters), [MERRA2](https://disc.gsfc.nasa.gov/datasets/M2TMNXRAD_5.12.4/summary)
Does anyone know if including time-specific albedo this has been shown to be even more important with bifacials?

(I would think yes.)
> Does anyone know if including time-specific albedo this has been shown to be even more important with bifacials?
> 
> (I would think yes.)

Yes, it is more important than for single-sided modules. There are ground surfaces where the albedo depends on the solar elevation and hence time of day.

One caution about albedo from satellite-derived irradiance: those values are at least km^2 scale, and are observed from space, whereas a PV model is assuming that the albedo is localized (m^2) and has been determined from the irradiance reaching the ground. [SolarAnywhere ](https://www.solaranywhere.com/support/data-fields/albedo/)provides an informative list of caveats.

The good news is that the uncertainty in albedo is typically secondary to uncertainty in other data such as GHI, when considering uncertainty in energy production.

Which is the better course of action?

1. Leave `albedo` on `PVsystem` or `Array`. Edit the docstrings and add tests to make it explicit that `PVSystem.albedo` or `Array.albedo` can be a Series. Advantages: avoids deprecating and removing `PVSystem.albedo`. Downside: users obtaining albedo from weather data sources have an extra step to perform when using `ModelChain` methods.
2. Add `albedo` as an optional column in `weather`, and have `ModelChain` methods use `weather['albedo']` instead of `PVSystem.albedo` when `weather['albedo']` is present. Advantages: convenient for ModelChain users, and avoids deprecating `PVsystem.albedo`. Disadvatanges: potential for confusion when a user also assigns `PVSystem.albedo`. 
3. Move `albedo` from `PVSystem` to `weather`. Same advantages as 2, but requires deprecation, and adds an extra step for users who aren't getting albedo with weather data, and would probably lead to adding code to `ModelChain` similar to the code that infers albedo from `PVSystem.surface_type`.
@cwhanse I lean toward option 1. However, it seems that for option 1, a user might have to duplicate computations already done in the `ModelChain` in the preliminary step of using the weather to compute the existing `PVSystem.albedo` (as some formulaic combination of ground conditions and weather). Do you know if this is really an issue?
Thanks for the discussion around this feature.  I favor Option 2, noting that PVSystem.albedo is already an optional argument.  Option 1 is prone to bugs and cases need to be handled checking for mismatches in series/dataframe lengths or perhaps same series lengths but different indices.  I would discourage Option 3, as it seems there is both a basis for and utility in retaining albedo as a property of PVSystem.
For option 2, I would say raise an exception (or at very least a warning) if two albedos are specified. This could definitely be the source of a subtle computational bug when users don't realize a weather file they pulled is doing something they didn't intend.
+1 for option 2, and I agree with @campanelli-sunpower that an exception should be raised if two albedos are specified
+1 for option 2, but I like keeping the old method for the case where you just want to set either a single annual albedo or monthly albedos (tho not sure if this option currently exists). I agree also raise exception if both are specified - we can always change it later.