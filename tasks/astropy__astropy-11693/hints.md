Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/master/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

If you feel that this issue has not been responded to in a timely manner, please leave a comment mentioning our software support engineer @embray, or send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
You could also directly call

```python
pixel = self.all_world2pix(*world_arrays, 0)
pixel = pixel[0] if self.pixel_n_dim == 1 else tuple(pixel)
```

without patching any code.  But I wonder if the WCSAPI methods shouldn't allow passing additional keyword args to the underlying WCS methods (like `all_world2pix` in this case).  @astrofrog is the one who first introduces this API I think.
I think the cleanest fix here would be that really the FITS WCS APE14 wrapper should call all_* in a way that only emits a warning not raises an exception (since by design we can't pass kwargs through). It's then easy for users to ignore the warning if they really want.

@Cadair any thoughts?

Is this technically a bug?
> the FITS WCS APE14 wrapper should call all_* in a way that only emits a warning

This is probably the best solution. I certainly can't think of a better one.

On keyword arguments to WCSAPI, if we did allow that we would have to mandate that all implementations allowed `**kwargs` to accept and ignore all unknown kwargs so that you didn't make it implementation specific when calling the method, which is a big ugly.
> Is this technically a bug?

I would say so yes.
> > the FITS WCS APE14 wrapper should call all_* in a way that only emits a warning
> 
> This is probably the best solution. I certainly can't think of a better one.
> 

That solution would be also fine for me.


@karlwessel , are you interested in submitting a patch for this? 😸 
In principle yes, but at the moment I really can't say.

Which places would this affect? Only all calls to `all_*` in `wcsapi/fitswcs.py`?
Yes I think that's right
For what it is worth, my comment is about the issues with the example. I think so far the history of `all_pix2world` shows that it is a very stable algorithm that converges for all "real" astronomical images. So, I wanted to learn about this failure. [NOTE: This does not mean that you should not catch exceptions in `pixel_to_world()` if you wish so.]

There are several issues with the example:
1. Because `CTYPE` is not set, essentially the projection algorithm is linear, that is, intermediate physical coordinates are the world coordinates.
2. SIP standard assumes that polynomials share the same CRPIX with the WCS. Here, CRPIX of the `Wcsprm` is `[0, 0]` while the CRPIX of the SIP is set to `[1221.87375165,  994.90917378]`
3. If you run `wcs.all_pix2world(1, 1, 1)` you will get `[421.5126801, 374.13077558]` for world coordinates (and at CRPIX you will get CRVAL which is 0). This is in degrees. You can see that from the center pixel (CRPIX) to the corner of the image you are circling the celestial sphere many times (well, at least once; I did not check the other corners).

In summary, yes `all_world2pix` can fail but it does not imply that there is a bug in it. This example simply contains large distortions (like mapping `(1, 1) -> [421, 374]`) that cannot be handled with the currently implemented algorithm but I am not sure there is another algorithm that could do better.

With regard to throwing or not an exception... that's tough. On one hand, for those who are interested in correctness of the values, it is better to know that the algorithm failed and one cannot trust returned values. For plotting, this may be an issue and one would prefer to just get, maybe, the linear approximation. My personal preference is for exceptions because they can be caught and dealt with by the caller.
The example is a minimal version of our real WCS whichs nonlinear distortion is taken from a checkerboard image and it fits it quit well:
![fitteddistortion](https://user-images.githubusercontent.com/64231/116892995-be892a00-ac30-11eb-826f-99e3635af1fa.png)

The WCS was fitted with `fit_wcs_from_points` using an artificial very small 'RA/DEC-TAN' grid so that it is almost linear.

I guess the Problem is that the camera really has a huge distortion which just isn't fitable with a polynomial. Nevertheless it still is a real camera distortion, but I agree in that it probably is not worth to be considered a bug in the `all_world2pix` method.
Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/master/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

If you feel that this issue has not been responded to in a timely manner, please leave a comment mentioning our software support engineer @embray, or send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
You could also directly call

```python
pixel = self.all_world2pix(*world_arrays, 0)
pixel = pixel[0] if self.pixel_n_dim == 1 else tuple(pixel)
```

without patching any code.  But I wonder if the WCSAPI methods shouldn't allow passing additional keyword args to the underlying WCS methods (like `all_world2pix` in this case).  @astrofrog is the one who first introduces this API I think.
I think the cleanest fix here would be that really the FITS WCS APE14 wrapper should call all_* in a way that only emits a warning not raises an exception (since by design we can't pass kwargs through). It's then easy for users to ignore the warning if they really want.

@Cadair any thoughts?

Is this technically a bug?
> the FITS WCS APE14 wrapper should call all_* in a way that only emits a warning

This is probably the best solution. I certainly can't think of a better one.

On keyword arguments to WCSAPI, if we did allow that we would have to mandate that all implementations allowed `**kwargs` to accept and ignore all unknown kwargs so that you didn't make it implementation specific when calling the method, which is a big ugly.
> Is this technically a bug?

I would say so yes.
> > the FITS WCS APE14 wrapper should call all_* in a way that only emits a warning
> 
> This is probably the best solution. I certainly can't think of a better one.
> 

That solution would be also fine for me.


@karlwessel , are you interested in submitting a patch for this? 😸 
In principle yes, but at the moment I really can't say.

Which places would this affect? Only all calls to `all_*` in `wcsapi/fitswcs.py`?
Yes I think that's right
For what it is worth, my comment is about the issues with the example. I think so far the history of `all_pix2world` shows that it is a very stable algorithm that converges for all "real" astronomical images. So, I wanted to learn about this failure. [NOTE: This does not mean that you should not catch exceptions in `pixel_to_world()` if you wish so.]

There are several issues with the example:
1. Because `CTYPE` is not set, essentially the projection algorithm is linear, that is, intermediate physical coordinates are the world coordinates.
2. SIP standard assumes that polynomials share the same CRPIX with the WCS. Here, CRPIX of the `Wcsprm` is `[0, 0]` while the CRPIX of the SIP is set to `[1221.87375165,  994.90917378]`
3. If you run `wcs.all_pix2world(1, 1, 1)` you will get `[421.5126801, 374.13077558]` for world coordinates (and at CRPIX you will get CRVAL which is 0). This is in degrees. You can see that from the center pixel (CRPIX) to the corner of the image you are circling the celestial sphere many times (well, at least once; I did not check the other corners).

In summary, yes `all_world2pix` can fail but it does not imply that there is a bug in it. This example simply contains large distortions (like mapping `(1, 1) -> [421, 374]`) that cannot be handled with the currently implemented algorithm but I am not sure there is another algorithm that could do better.

With regard to throwing or not an exception... that's tough. On one hand, for those who are interested in correctness of the values, it is better to know that the algorithm failed and one cannot trust returned values. For plotting, this may be an issue and one would prefer to just get, maybe, the linear approximation. My personal preference is for exceptions because they can be caught and dealt with by the caller.
The example is a minimal version of our real WCS whichs nonlinear distortion is taken from a checkerboard image and it fits it quit well:
![fitteddistortion](https://user-images.githubusercontent.com/64231/116892995-be892a00-ac30-11eb-826f-99e3635af1fa.png)

The WCS was fitted with `fit_wcs_from_points` using an artificial very small 'RA/DEC-TAN' grid so that it is almost linear.

I guess the Problem is that the camera really has a huge distortion which just isn't fitable with a polynomial. Nevertheless it still is a real camera distortion, but I agree in that it probably is not worth to be considered a bug in the `all_world2pix` method.