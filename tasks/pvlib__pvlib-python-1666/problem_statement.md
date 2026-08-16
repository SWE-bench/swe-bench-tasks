is vf_row_sky correct?
https://github.com/pvlib/pvlib-python/blob/7e88d212c786d0ad334dce6fcafaf29339ff60ab/pvlib/bifacial/infinite_sheds.py#L146

I think this should be:

$$\frac{1 + \cos \left( \text{surface tilt} + \psi_{t}\ \text{shaded} \right)}{2}$$

because in the reference frame of the module surface the angle pointing along the slant height to the sky is actually zero, $cos(0) = 1$, and the angle above the slant height to a horizontal line would be the `surface_tilt` itself, then the angle from the horizontal to the top of the next row is `psi_t_shaded` so finally this angle from the slant height all the way up to the top of the next row is `surface_tilt + psi_t_shaded`:

![infinite_sheds](https://user-images.githubusercontent.com/1385621/218985907-7fced67c-ccff-439f-8fc8-0774026b9501.png)

For example, this is why if `psi_t_shaded` is zero, then the view factor should collapse to the isotropic view factor $(1+\cos(\beta))/2$ as given on the [PVPMC website modeling reference for POA sky diffuse](https://pvpmc.sandia.gov/modeling-steps/1-weather-design-inputs/plane-of-array-poa-irradiance/calculating-poa-irradiance/poa-sky-diffuse/isotropic-sky-diffuse-model/).

The actual value difference between the two formulas can be quite small when `psi_t_shaded` is close to zero (_eg_ less than 5&deg;), but it's significant when as the masking angle is larger (_eg_ greater than 5&deg;).
