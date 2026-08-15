A slightly shorter script to reproduce the issue is this (starting from the definition of `fits_wcs` in the OP):

```python
sl = SlicedLowLevelWCS(fits_wcs, 0)
world = fits_wcs.pixel_to_world_values(0,0,0)
out_pix = sl.world_to_pixel_values(world[0], world[1])

assert np.allclose(out_pix[0], 0)
```

The root of the issue here is this line:

https://github.com/astropy/astropy/blob/0df94ff7097961e92fd7812036a24b145bc13ca8/astropy/wcs/wcsapi/wrappers/sliced_wcs.py#L253-L254

the value of `1` here is incorrect, it needs to be the world coordinate corresponding to the pixel value in the slice so that the inverse transform works as expected.