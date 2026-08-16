deprecate existing code in forecast.py, possibly replace with solarforecastarbiter shim
`forecast.py` is a burden to maintain. I haven't used it in years, I don't think any of the other pvlib maintainers are interested in it, and I don't see any users stepping up to volunteer to maintain it. The code is not up to my present standards and I don't see how I'd get it there without a complete rewrite. This leads to difficult to track bugs such as the one recently reported on the [google group](https://groups.google.com/g/pvlib-python/c/b9HdgWV6w6g). It also complicates the pvlib dependencies.

[solarforecastarbiter](https://github.com/SolarArbiter/solarforecastarbiter-core) includes a [reference_forecasts](https://github.com/SolarArbiter/solarforecastarbiter-core/tree/master/solarforecastarbiter/reference_forecasts) package that is much more robust. See [documentation here](https://solarforecastarbiter-core.readthedocs.io/en/latest/reference-forecasts.html) and [example notebook here](https://github.com/SolarArbiter/workshop/blob/master/reference_forecasts.ipynb) (no promises that this works without modification for the latest version).

The main reason to prefer `forecast.py` to `solarforecastarbiter` is the data fetch process. `forecast.py` pulls point data from a Unidata THREDDS server. `solarforecastarbiter.reference_forecasts` assumes you already have gridded data stored in a netcdf file. `solarforecastarbiter.io.nwp` provides functions to fetch that gridded data from NCEP. We have very good reasons for that approach in `solarforecastarbiter`, but I doubt that many `forecast.py` users are interested in configuring that two step process for their application.

I'm very tempted to stop here, remove `forecast.py` after deprecation, and say "not my problem anymore", but it seems to attract a fair number of people to pvlib, so I hesitate to remove it without some kind of replacement. Let's explore a few ideas.

1. Within `forecast.py`, rewrite code to fetch relevant data from Unidata. Make this function compatible with the expectations for the [`load_forecast`](https://github.com/SolarArbiter/solarforecastarbiter-core/blob/6200ec067bf83bc198a3af59da1d924d4124d4ec/solarforecastarbiter/reference_forecasts/models.py#L16-L19) function passed into `solarforecastarbiter.reference_forecasts.models` functions.
2. Same as 1., except put that code somewhere else. Could be a documentation example, could be in solarforecastarbiter, or could be in a gist.
3. Copy/refactor solarforecastarbiter code into `forecast.py`.
4. Do nothing and let the forecast.py bugs and technical debt pile up. 

Other thoughts?
