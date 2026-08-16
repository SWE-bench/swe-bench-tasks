Consider also specifying it is relative airmass.
This came up again in @mikofski's thread [here](https://groups.google.com/g/pvlib-python/c/AUQ_hsbL_B8/m/0y83YIRrBgAJ). 

@mikofski proposed calculating values if needed and not provided.

@kanderso-nrel proposed a couple of solutions to provide more informative error messages: 1. hard coding the failure modes in `get_sky_diffuse` and 2. using a decorator to communicate the failure modes.

And repeating my take from the thread:

I'd rather not introduce the complexity of decorators to the lower level pvlib functions to solve this problem.

Ideas that I support:
* calculate if not provided (Mark's original idea)
* reraising a more informative message.
* require all of the arguments in get_sky_diffuse and get_total_irradiance regardless of whether or not they're used.
* remove the arguments from get_sky_diffuse and get_total_irradiance and do the calculation if it's needed
* ~remove get_sky_diffuse and get_total_irradiance. I'm not convinced they're a net positive for the library.~ (let's try to fix it before throwing up our hands)

Does someone want to tackle this in 0.8.0 or should we kick it down the road?
I think it's tempting to add it in v0.8, but I'm in favor of freezing features now and pushing out the release sooner with the features we already have queued. It's been a while, and I think we should deploy more often with less features per release. I believe this will make it easier to blame issues and get more testing done on new features and fixes faster.
I'll volunteer to take this up for v0.8.1, since I was the complainer.
`PVSystem.get_irradiance` has some relevant shim code:

https://github.com/pvlib/pvlib-python/blob/04a523fafbd61bc2e49420963b84ed8e2bd1b3cf/pvlib/pvsystem.py#L289-L294