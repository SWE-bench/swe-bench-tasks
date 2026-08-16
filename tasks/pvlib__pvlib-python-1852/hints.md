I'm in favor of pvlib being able to handle asymmetrical rotation limits in principle, but I'm curious what situation has that asymmetry in practice.  @MichalArieli do you have a particular real-world application in mind?

Rather than separate `min_` and `max_` parameters, I think I'd favor a single parameter that accepts a tuple as @cwhanse suggested here: https://github.com/pvlib/pvlib-python/pull/823#issuecomment-561399605.  I'm not sure about renaming `max_angle` to something else though.  `singleaxis(..., max_angle=(-40, 45))` seems okay to me.  And since symmetrical limits is by far the more common case, I think the parameter should continue accepting a single value (in which case symmetry is assumed) in addition to a tuple.

`tracking.SingleAxisTracker` is being removed anyway (#1771), so no point in making any additions there.  Whatever changes we decide on here should only be made to `tracking.singleaxis` and `pvsystem.SingleAxisTrackerMount` (and tests, of course).
@kandersolar  Thanks for the quick response! 

Regarding handling asymmetry in rotation limits, let's take the example of a tracker placed at a 90-degree axis azimuth, tracking south-north. If the sun is at azimuth 80 degrees during sunrise, the algorithm will guide the tracker to briefly turn north. To prevent that we can implement a maximum angle limit for northward movement to ensure smooth and continuous motion and taking into account the time needed for such a large angular change.

I agree its better to have a single parameter that accepts a tuple/ single value. Would you like me to apply these changes and send for a PR? 

> Would you like me to apply these changes and send for a PR?

Please do!