`git blame` points out that @eteq or @mhvk might be able to clarify.
Yes, logically, those `False` ones should be replaced by `u.radian` (or, perhaps better, `nutation_components200B` should just return values in angular units, and the `False` can be removed altogether).

What I am surprised about, though, is that this particular routine apparently is neither used nor tested. Isn't all this stuff in `erfa`? Indeed, more generally, could we make these routines wrappers around `erfa`?

@zhutinglei - separately, it might help to understand why you needed the nutation? Are we missing a coordinate transform?
Thanks for the quick response @mhvk . 

First, answer your question on why I need the nutation. I am trying to get the position velocity vector of an observatory (of type `EarthLocation`), in J2000.0 Geocentric Celestial Reference Frame (i.e. mean equinox, mean equator at epoch J2000.0). Although the class `EarthLocation` provide  `get_gcrs_posvel()`, I failed to find the document that describes it. As a result, I decided to write my own code to do this, and then I need the precession and nutation matrix. Another minor cause is that sometimes I do not need polar motion (it is too small compared with precision I need), but it seems that I cannot choose to close polar motion when I call `get_gcrs_posvel()`. Hence I need to code my own transformation with only precession and nutation. Is there any documentation helpful?

In addition, actually, I also need TEME (true equator, mean equinox) coordinate system, which is used by Two-Line Element (TLE). Currently, I simply use the rotation matrix Rz(-\mu-\Delta\mu), where \mu and \Delta\mu are precession and nutation angle in right ascension, to transform vectors from TOD (true of date, i.e. true equator, true equinox) frame to TEME frame. It might help if you add the coordinate transform related with TEME.
@zhutinglei - the little documentation we have is indeed sparse [1], [2]; where exactly would it help you to be clearer about what happens?

On your actual problem, I *think* `get_gcrs_posvel` is all you should need if you just want x, y, z - you can then use the result to define a frame in which an object is observed to pass on `obsgeopos` and `obsgeovel`.  If you want an actual J2000 GCRS coordinate, the standard route would be via `ITRS`:
```
el = EarthLocation(...)
gcrs = el.get_itrs().transform_to(GCRS)
gcrs
# GCRS Coordinate (obstime=J2000.000, obsgeoloc=( 0.,  0.,  0.) m, obsgeovel=( 0.,  0.,  0.) m / s): (ra, dec, distance) in (deg, deg, m)
#     ( 325.46088987,  29.83393221,  6372824.42030426)>
gcrs.cartesian
# <CartesianRepresentation (x, y, z) in m
#     ( 4553829.11686306, -3134338.92680929,  3170402.33382524)>
```
This is the same as the position from `get_gcrs_posvel`:
```
el.get_gcrs_posvel(obstime=Time('J2000'))
# (<CartesianRepresentation (x, y, z) in m
#      ( 4553829.11686306, -3134338.92680929,  3170402.33382524)>,
#  <CartesianRepresentation (x, y, z) in m / s
#      ( 228.55962584,  332.07049505,  0.)>)
```

On the remainder: I'm confused about what you mean by "cannot choose to close polar motion" - what exactly would you hope to do?

Finally, on `TEME`, I'll admit I'm not sure what this is. I'm cc'ing @eteq and @StuartLittlefair, who might be more familiar (they may also be able to correct me if I'm wrong above). If it is a system that is regularly used, then ideally we'd support it. (@eteq - see also my more general [question](https://github.com/astropy/astropy/issues/6583#issuecomment-331180713) about why we have a nutation routine that is neither used nor tested!)

[1] http://docs.astropy.org/en/latest/api/astropy.coordinates.EarthLocation.html#astropy.coordinates.EarthLocation.get_gcrs_posvel
[2] http://docs.astropy.org/en/latest/api/astropy.coordinates.GCRS.html#astropy.coordinates.GCRS
@zhutinglei 

Thanks for raising this issue. Depending on the precision you need @mhvk's code may be fine. ```get_gcrs_posvel``` returns Earth-centred coordinates aligned with the ```GCRF```/```ICRF``` reference frames. 

What you seem to want is an Earth-centred equivalent to FK5 (i.e a mean equatorial frame with J2000) epoch. That does not exist in astropy, but the GCRS coordinate returned by ```get_gcrs_posvel``` is consistent with it to [around 80 mas](https://www.iers.org/IERS/EN/Science/ICRS/ICRS.html).

With respect to TEME; I am only vaguely familiar with it. I understand it's an Earth-centred coordinate with the z-axis aligned to the true direction of the pole, but the x-axis aligned with the mean equinox? It does not yet exist in astropy, but @eteq has a nice tutorial for adding new frames [here](http://docs.astropy.org/en/stable/generated/examples/coordinates/plot_sgr-coordinate-frame.html), which you could follow if you need it.

On the other hand, if you simply want an easy way to work with TLE files, I note that @brandon-rhodes [Skyfield](http://rhodesmill.org/skyfield/earth-satellites.html) package is already setup to read and perform calculations with TLE files...
Oops, we never got around to actually fixing this - and probably deprecate in favour of some erfa routine - and now we've got a duplicate - #10680 

p.s. For anyone who happens to hit this issue and needs `TEME` - it is now available, see https://docs.astropy.org/en/latest/api/astropy.coordinates.builtin_frames.TEME.html#astropy.coordinates.builtin_frames.TEME