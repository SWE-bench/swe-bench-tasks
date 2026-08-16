Improve docstring or behavior for irradiance.get_total_irradiance and irradiance.get_sky_diffuse
`pvlib.irradiance.get_total_irradiance` accepts kwargs `dni_extra` and `airmass`, both default to `None`. However, values for these kwargs are required for several of the irradiance transposition models. 

See discussion [here](https://groups.google.com/d/msg/pvlib-python/ZPMdpQOD6F4/cs1t23w8AwAJ)

Docstring should specify when `dni_extra` and `airmass` are required, and which airmass is appropriate for each model.

Could also test for kwarg values if e.g. `model=='perez'`
