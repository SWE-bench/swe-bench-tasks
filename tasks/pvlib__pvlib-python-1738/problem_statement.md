`pvlib.soiling.hsu` takes `tilt` instead of `surface_tilt`
`pvlib.soiling.hsu` takes a `tilt` parameter representing the same thing we normally call `surface_tilt`:

https://github.com/pvlib/pvlib-python/blob/7a2ec9b4765124463bf0ddd0a49dcfedc4cbcad7/pvlib/soiling.py#L13-L14

https://github.com/pvlib/pvlib-python/blob/7a2ec9b4765124463bf0ddd0a49dcfedc4cbcad7/pvlib/soiling.py#L33-L34

I don't see any good reason for this naming inconsistency (I suspect `tilt` just got copied from the matlab implementation) and suggest we rename the parameter to `surface_tilt` with a deprecation.

Also, the docstring parameter type description says it must be `float`, but the model's reference explicitly says time series tilt is allowed: 

> The angle is variable for tracking systems and is taken as the average angle over the time step.


