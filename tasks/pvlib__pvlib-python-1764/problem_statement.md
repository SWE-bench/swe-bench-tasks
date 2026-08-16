Allow user to set tol and maxiter for singlediode newton method
The first few lines of `pvlib.singlediode` set `tol` and `maxiter` for all the solvers using the newton method:

```
from scipy.optimize import brentq, newton
from scipy.special import lambertw

# set keyword arguments for all uses of newton in this module
newton = partial(newton, tol=1e-6, maxiter=100, fprime2=None)
```

However, I would like to change `tol` and `maxiter` for my application. It would be great if these could be added instead as keyword arguments to the various functions so they can be adjusted by the user. Using a variety of singlediode model params, I have found that by setting tol=0.1 and maxiter=10, I can realize a 1.4x speedup in the `singeldiode.bishop88_mpp` algorithm while incurring a maximum error of 0.007038% and a mean absolute error of  0.000042% in calculated V_mp.


