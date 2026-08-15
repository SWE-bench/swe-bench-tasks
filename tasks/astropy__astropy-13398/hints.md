cc @StuartLittlefair, @adrn, @eteq, @eerovaher, @mhvk 
Yes, would be good to address this recurring problem. But we somehow have to ensure it gets used only when relevant. For instance, the coordinates better have a distance, and I suspect it has to be near Earth...
Yeah, so far I've made no attempt at hardening this against unit spherical representations, Earth locations that are `None`, etc. I'm not sure why the distance would have to be near Earth though. If it was a megaparsec, that would just mean that there would be basically no difference between the geocentric and topocentric coordinates.
I'm definitely in favour of the approach. As @mhvk says it would need some error handling for nonsensical inputs. 

Perhaps some functionality can be included with an appropriate warning? For example, rather than blindly accepting the `obstime` of the output frame, one could warn the user that the input frame's `obstime` is being ignored, explain why, and suggest transforming explicitly via `ICRS` if this is not desired behaviour?

In addition, we could handle coords without distances this way, by assuming they are on the geoid with an appropriate warning?
Would distances matter for aberration? For most applications, it seems co-moving with the Earth is assumed. But I may not be thinking through this right.
The `obstime` really is irrelevant for the transform. Now, I know that Astropy ties everything including the kitchen sink tied to the SBB and, should one dare ask where that sink will be in an hour, it will happily tear it right out of the house and throw it out into space.  But is doesn't necessarily have to be that way. In my view an ITRS<->ITRS transform should be a no-op. Outside of earthquakes and plate tectonics, the ITRS coordinates of stationary objects on the surface of the Earth are time invariant and nothing off of the surface other than a truly geostationary satellite has constant ITRS coordinates. The example given in issue #13319 uses an ILRS ephemeris with records given at 3 minute intervals. This is interpolated using an 8th (the ILRS prescribes 9th) order lagrange polynomial to yield the target body ITRS coordinates at any given time. I expect that most users will ignore `obstime` altogether, although some may include it in the output frame in order to have a builtin record of the times of observation. In no case will an ITRS<->ITRS transform from one time to another yield an expected result as that transform is currently written.

I suppose that, rather than raising an exception, we could simply treat unit vectors as topocentric and transform them from one frame to the other. I'm not sure how meaningful this would be though. Since there is currently no way to assign an `EarthLocation` to an ITRS frame, it's much more likely to have been the result of a mistake on the part of the user. The only possible interpretation is that the target body is at such a distance that the change in direction due to topocentric parallax is insignificant. Despite my megaparsec example, that is not what ITRS coordinates are about. The only ones that I know of that use ITRS coordinates in deep space are the ILRS (they do the inner planets out to Mars) and measuring distance is what they are all about.

Regarding aberration, I did some more research on this. The ILRS ephemerides do add in stellar aberration for solar system bodies. Users of these ephemerides are well aware of this. Each position has an additional record that gives the geocentric stellar aberration corrections to the ITRS coordinates. Such users can be directed in the documentation to use explicit ITRS->ICRS->Observed transforms instead.

Clear and thorough documentation will be very important for these transforms. I will be careful to explain what they provide and what they do not. 

Since I seem to have sufficient support here, I will proceed with this project. As always, further input is welcome.
> The `obstime` really is irrelevant for the transform. Now, I know that Astropy ties everything including the kitchen sink to the SBB and, should one dare ask where that sink will be in an hour, it will happily tear it right out of the house and throw it out into space. But is doesn't necessarily have to be that way. In my view an ITRS<->ITRS transform should be a no-op. Outside of earthquakes and plate tectonics, the ITRS coordinates of stationary objects on the surface of the Earth are time invariant…

This is the bit I have a problem with as it would mean that ITRS coordinates would behave in a different way to every other coordinate in astropy. 

In astropy I don’t think we make any assumptions about what kind of object the coordinate points to. A coordinate is a point in spacetime, expressed in a reference frame, and that’s it. 

In the rest of astropy we treat that point as fixed in space and if the reference frame moves, so do the coordinates in the frame. 

Arguably that isn’t a great design choice, and it is certainly the cause of much confusion with astropy coordinates. However, we are we are and I don’t think it’s viable for some frames to treat coordinates that way and others not to - at least not without a honking great warning to the user that it’s happening. 
It sounds to me like `SkyCoord` is not the best class for describing satellites, etc., since, as @StuartLittlefair notes, the built-in assumption is that it is an object for which only the location and velocity are relevant (and thus likely distant). We already previously found that this is not always enough for solar system objects, and discussed whether a separate class might be useful. Perhaps here similarly one needs a different (sub)class that comes with a transformation graph that makes different assumptions/shortcuts? Alternatively, one could imagine being able to select the shortcuts suggested here with something like a context manager.
Well, I was just explaining why I am ignoring any difference in `obstime` between the input and output frames for this transform. This won't break anything. I'll just state in the documentation that this is the case. I suppose that, if `obstimes` are present in both frames, I can raise an exception if they don't match.
Alternately, I could just go ahead and do the ITRS<->ITRS transform, If you would prefer. Most of the time, the resulting error will be obvious to the user, but this could conceivably cause subtle errors if somehow the times were off by a small fraction of a second.
> It sounds to me like SkyCoord is not the best class for describing satellites, etc.

Well, that's what TEME is for. Doing a TEME->Observed transform when the target body is a satellite will cause similar problems if the `obstimes` don't match. This just isn't explicitly stated in the documentation. I guess it is just assumed that TEME users know what they are doing.

Sorry about the stream of consciousness posting here. It is an issue that I sometimes have. I should think things through thoroughly before I post.
> Well, I was just explaining why I am ignoring any difference in `obstime` between the input and output frames for this transform. This won't break anything. I'll just state in the documentation that this is the case. I suppose that, if `obstimes` are present in both frames, I can raise an exception if they don't match.

I think we should either raise an exception or a warning if obstimes are present in both frames for now. The exception message can suggest the user tries ITRS -> ICRS -> ITRS' which would work.

As an aside, in general I'd prefer a solution somewhat along the lines @mhvk suggests, which is that we have different classes to represent real "things" at given positions, so a `SkyCoord` might transform differently to a `SatelliteCoord` or an `EarthCoord` for example. 

However, this is a huge break from what we have now. In particular the way the coordinates package does not cleanly separate coordinate *frames* from the coordinate *data* at the level of Python classes causes us some difficulties here if decided to go down this route. 

e.g At the moment, you can have an `ITRS` frame with some data in it, whereas it might be cleaner to prevent this, and instead implement a series of **Coord objects that *own* a frame and some coordinate data...
Given the direction that this discussion has gone, I want to cross-reference related discussion in #10372 and #10404.  [A comment of mine from November 2020(!)](https://github.com/astropy/astropy/issues/10404#issuecomment-733779293) was:
> Since this PR has been been mentioned elsewhere twice today, I thought I should affirm that I haven't abandoned this effort, and I'm continuing to mull over ways to proceed.  My minor epiphany recently has been that we shouldn't be trying to treat stars and solar-system bodies differently, but rather we should be treating them the *same* (cf. @mhvk's mention of Barnard's star).  The API should instead distinguish between apparent locations and true locations.  I've been tinkering on possible API approaches, which may include some breaking changes to `SkyCoord`.

I sheepishly note that I never wrote up the nascent proposal in my mind.  But, in a nutshell, my preferred idea was not dissimilar to what has been suggested above:

- `TrueCoord`: a new class, which would represent the *true* location of a thing, and must always be 3D.  It would contain the information about how its location evolves over time, whether that means linear motion, Keplerian motion, ephemeris lookup, or simply fixed in inertial space.
- `SkyCoord`: similar to the existing class, which would represent the *apparent* location of a `TrueCoord` for a specific observer location, and can be 2D.  That is, aberration would come in only with `SkyCoord`, not with `TrueCoord`.  Thus, a transformation of a `SkyCoord` to a different `obstime` would go `SkyCoord(t1)`->`TrueCoord(t1)`->`TrueCoord(t2)`->`SkyCoord(t2)`.

I stalled out developing this idea further as I kept getting stuck on how best to modify the existing API and transformations.
I like the idea, though the details may be tricky. E.g., suppose I have (GAIA) astrometry of a binary star 2 kpc away, then what does `SkyCoord(t1)->TrueCoord(t1)` mean? What is the `t1` for `TrueCoord`? Clearly, it needs to include travel time, but relative to what? 
Meanwhile, I took a step back and decided that I was thinking about this wrong. I was thinking of basically creating a special case for use with satellite observations that do not include stellar aberration corrections, when I should have been thinking of how to fit these observations into the current framework so that they play nicely with Astropy. What I came up with is an actual topocentric ITRS frame. This will be a little more work, but not much. I already have the ability to transform to and from topocentric ITRS and Observed with the addition and removal of refraction tested and working. I just need to modify the intermediate transforms ICRS<->CIRS and ICRS<->TETE to work with topocentric ICRS, but this is actually quite simple to do. This also has the interesting side benefit of creating a potential path from TETE to observed without having to go back through GCRS, which would be much faster.

Doing this won't create a direct path for satellite observations from geocentric ITRS to Observed without stellar aberration corrections, but the path that it does create is much more intuitive as all they need to do is subtract the ITRS coordinates of the observing site from the coordinates of the target satellite, put the result into a topocentric ITRS frame and do the transform to Observed.
> I like the idea, though the details may be tricky. E.g., suppose I have (GAIA) astrometry of a binary star 2 kpc away, then what does `SkyCoord(t1)->TrueCoord(t1)` mean? What is the `t1` for `TrueCoord`? Clearly, it needs to include travel time, but relative to what?

My conception would be to linearly propagate the binary star by its proper motion for the light travel time to the telescope (~6500 years) to get its `TrueCoord` position.  That is, the transformation would be exactly the same as a solar-system body with linear motion, just much much further away.  The new position may be a bit non-sensical depending on the thing, but the `SkyCoord`->`TrueCoord`->`TrueCoord`->`SkyCoord` loop for linear motion would cancel out all of the extreme part of the propagation, leaving only the time difference (`t2-t1`).

I don't want to distract from this issue, so I guess I should finally write this up more fully and create a separate issue for discussion.
@mkbrewer - this sounds intriguing but what precisely do you mean by "topocentric ITRS"? ITRS seems geocentric by definition, but I guess you are thinking of some extension where coordinates are relative to a position on Earth? Would that imply a different frame for each position?

@ayshih - indeed, best to move to a separate issue. I'm not sure that the cancellation would always work out well enough, but best to think that through looking at a more concrete proposal. 
Yes. I am using CIRS as my template. No. An array of positions at different `obstimes` can all have the location of the observing site subtracted and set in one frame. That is what I did in testing. I used the example script from #13319, which has three positions in each frame.
I'm having a problem that I don't know how to solve. I added an `EarthLocation` as an argument for ITRS defaulting to `.EARTH_CENTER`. When I create an ITRS frame without specifying a location, it works fine:
```
<ITRS Coordinate (obstime=J2000.000, location=(0., 0., 0.) km): (x, y, z) [dimensionless]
    (0.00239357, 0.70710144, 0.70710144)>
```
But if I try to give it a location, I get: 
```
Traceback (most recent call last):
  File "/home/mkbrewer/ilrs_test6.py", line 110, in <module>
    itrs_frame = astropy.coordinates.ITRS(dpos.cartesian, location=topo_loc)
  File "/etc/anaconda3/lib/python3.9/site-packages/astropy/coordinates/baseframe.py", line 320, in __init__
    raise TypeError(
TypeError: Coordinate frame ITRS got unexpected keywords: ['location']
```

Oh darn. Never mind. I see what I did wrong there.