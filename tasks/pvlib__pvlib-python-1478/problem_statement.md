ModelChain should accept albedo in weather dataframe
**Is your feature request related to a problem? Please describe.**
Albedo is treated as a scalar constant in pvlib, but it is of course a function of the weather and changes throughout the year.  Albedo is currently set in the PVSystem or Array and cannot be altered using the ModelChain.  Albedo is provided as a timeseries from many weather data services as well as through NREL's NSRBD and it would be useful to provide this data to the ModelChain.

Additionally, treating albedo as property of the Array seems to conflict with the [PVSystem Design Philosophy](https://pvlib-python.readthedocs.io/en/stable/pvsystem.html#design-philosophy), which highlights the separation of the PV system and the exogenous variables, such as the weather.

**Describe the solution you'd like**
ModelChain.run_model() should accept albedo in the weather dataframe, like temperature and ghi.

**Describe alternatives you've considered**
An alternative we have implemented is calling ModelChain.run_model() on each row of a dataframe and manually updating the albedo of the array in each tilmestep.  This probably has some side effects that we are unaware of.

