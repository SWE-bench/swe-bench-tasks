Add Wavelet Variability Model (WVM) for calculating spatial smoothing of irradiance
> > Should I spin this off to a separate issue, since it might be different (and more compartmented) than the broader downscaling discussion?
> 
> Yes. Let's start a new module with this submission, `scaling.py` comes to mind, but I'm not enamored of it. Scope will be functions that operate on irradiance, perhaps other variables, to transform temporal or spatial characteristics.

Spinoff from [issue #788 ](https://github.com/pvlib/pvlib-python/issues/788). Implementation is a python port of WVM, released as an auxiliary to the Matlab pvlib [here](https://pvpmc.sandia.gov/applications/wavelet-variability-model/). My implementation ports the original model logic, but deviates from the overall package, in that I begin at the point where the user already has a clear sky index to operate on (original starts from GHI and calculates POA clear sky index). I thought this would allow for more flexibility in choice of transposition model, etc, but it does ask a bit more work up front for a user to run the WVM.

I am close to completion of a draft and will create a pull request when ready. This is my first contribution to the project (or any open source project really), so please accept my apologies in advance if it takes some guidance.
