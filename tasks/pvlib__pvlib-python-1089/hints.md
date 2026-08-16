Confirmed. Looks like it's a lack of convergence in `pvlib.singlediode._lambertw`.  Some time ago a similar issue was reported for PVLib Matlab, I think we bumped up the iteration count to fix it.

If you set `pvlib.singlediode(..., method='brentq',...)` the noise smooths away.
@cwhanse Thanks. `method='brentq'` fixed the issue for me too. :)

Since you're from Sandia, do have any insight about a "typical" sign of the T-coef for `I_mp` in the SAPM? It seems like the sign is positive for the PVsyst model and negative for the SAPM (~both~ in SOME CFV reports ~and by taking the derivative of `P_mp` = `I_mp` * `V_mp` w.r.t. `T` and solving for `dI_mp/ dT`~).

UPDATE: With the `I_mp` calculation correction, it appears that I get a consistent + sign for the `I_mp` temperature coefficient in both computational methods. However, I do see this reported as a negative value in some places.
I don't know that theory predicts a sign for this temperature coefficient.

For SAPM, when Sandia fits this model using outdoor measurements, a value is determined by fitting a line to Imp vs. cell temperature (backed out of Isc, Voc values). I've argued that given the resolution of measurements, the technique for determining cell temperature and maximum power point, and the regression method, that the value is usually statistically indistinguishable from zero.

For CFV-produced Pvsyst parameters, my guess is that CFV is determining alpha_imp by fitting a line to the Imp vs. cell temperature data (IEC61853 matrix test results using an indoor flasher with temperature variation control), which is the same method used by Sandia for the SAPM. Happy to connect you with CFV and you can ask them.
Thanks for sharing your understanding @cwhanse. I think I will have a convo with Daniel C. Zirzow at CFV at some point in the near future.

Should I close this issue, or should it become a PR to change defaults to better ensure convergence?
Leave it open, there's a pvlib issue to be addressed.

I tracked down the source of the oscillatory behavior to [this line](https://github.com/pvlib/pvlib-python/blob/3e25627e34bfd5aadea041da85a30626322b3a99/pvlib/singlediode.py#L611). 

```
        argW = Rs[idx_p] * I0[idx_p] / (
                    a[idx_p] * (Rs[idx_p] * Gsh[idx_p] + 1.)) * \
               np.exp((Rs[idx_p] * (IL[idx_p] + I0[idx_p]) + V[idx_p]) /
                      (a[idx_p] * (Rs[idx_p] * Gsh[idx_p] + 1.)))
```

It's a product of two terms:
constant factor : Rs * I0 / (a (Rs Gsh + 1))  which is very small (~1E-10) and
exponential factor: np.exp( (Rs * (IL + I0) + V) / (a * (Rs * Gsh + 1)) ) which is quite large (~1E+10), since the argument is ~20.

The constant factor increases smoothly with cell temperature, as expected. 

The argument of the exponential term decreases with temperature but not smoothly. The cause seems to be that Vmp (`V` in that line of code) decreases but not smoothly. Vmp is calculated using `pvlib.tools._golden_sect_DataFrame`. I suspect the convergence of this root finder is the culprit.

@cwhanse An incidental colleague of mine (Ken Roberts) figured out a way around the numerical convergence issues with using the LambertW function for solving the single diode equation. I have never had the time to do it full justice in code (I use simple newton in PVfit), but this "Log Wright Omega" function might be worth looking into for pvlib. Here are some references he shared with me. He was so pleasant to work with and I found his exposition very approachable.

- https://arxiv.org/pdf/1504.01964.pdf
- https://www.researchgate.net/publication/305991463