> Be lenient? E.g. only make the comparison up to float 32 precision?

Instead, we could make the comparison based on the precision of the ``dtype``, using something like https://numpy.org/doc/stable/reference/generated/numpy.finfo.html?highlight=finfo#numpy.finfo
That's a funny one! I think @nstarman's suggestion would work: would just need to change the dtype of `limit` to `self.dtype` in `_validate_angles`.
That wouldn't solve the case where the value is read from a float32 into a float64, which can happen pretty fast due to the places where casting can happen. Better than nothing, but...
Do we want to simply let it pass with that value, or rather "round" the input value down to the float64 representation of `pi/2`? Just wondering what may happen with larger values in any calculations down the line; probably nothing really terrible (like ending up with inverse Longitude), but...
This is what I did to fix it on our end:
https://github.com/cta-observatory/ctapipe/pull/2077/files#diff-d2022785b8c35b2f43d3b9d43c3721efaa9339d98dbff39c864172f1ba2f4f6f
```python
_half_pi = 0.5 * np.pi
_half_pi_maxval = (1 + 1e-6) * _half_pi




def _clip_altitude_if_close(altitude):
    """
    Round absolute values slightly larger than pi/2 in float64 to pi/2

    These can come from simtel_array because float32(pi/2) > float64(pi/2)
    and simtel using float32.

    Astropy complains about these values, so we fix them here.
    """
    if altitude > _half_pi and altitude < _half_pi_maxval:
        return _half_pi


    if altitude < -_half_pi and altitude > -_half_pi_maxval:
        return -_half_pi


    return altitude
```

Would that be an acceptable solution also here?
Does this keep the numpy dtype of the input?
No, the point is that this casts to float64.
So ``Latitude(pi/2, unit=u.deg, dtype=float32)``  can become a float64?
> Does this keep the numpy dtype of the input?

If `limit` is cast to `self.dtype` (is that identical to `self.angle.dtype`?) as per your suggestion above, it should.
But that modification should already catch the cases of `angle` still passed as float32, since both are compared at the same resolution. I'd vote to do this and only implement the more lenient comparison (for float32 that had already been upcast to float64)  as a fallback, i.e. if still `invalid_angles`, set something like
`_half_pi_maxval = (0.5 + np.finfo(np.float32).eps)) * np.pi` and do a second comparison to that, if that passes, set to  `limit * np.sign(self.angle)`. Have to remember that `self.angle` is an array in general...
> So `Latitude(pi/2, unit=u.deg, dtype=float32)` can become a float64?

`Latitude(pi/2, unit=u.rad, dtype=float32)` would in that approach, as it currently raises the `ValueError`.
I'll open a PR with unit test cases and then we can decide about the wanted behaviour for each of them