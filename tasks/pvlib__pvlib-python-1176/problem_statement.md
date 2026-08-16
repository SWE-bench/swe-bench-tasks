make Array play nicely with fixed tilt systems and trackers
#1076 is adding an `Array` class that largely describes a fixed-tilt array. However, the composition logic of `PVSystem: def __init__(arrays,...)` combined with the inheritance logic of `SingleAxisTracker(PVSystem)` makes for an odd combination of `Array` objects within `SingleAxisTrackers`. See, for example, https://github.com/pvlib/pvlib-python/pull/1076#discussion_r539704316. 

In https://github.com/pvlib/pvlib-python/pull/1076#discussion_r539686448 I proposed roughly:

Split the `Array` into `BaseArray`, `FixedTiltArray(BaseArray)`, `SingleAxisTrackingArray(BaseArray)`? Basic idea:

```python
class FixedTiltArray(BaseArray)
    """
    Parameters
    ----------
    surface_tilt: float or array-like, default 0
        Surface tilt angles in decimal degrees.
        The tilt angle is defined as degrees from horizontal
        (e.g. surface facing up = 0, surface facing horizon = 90)

    surface_azimuth: float or array-like, default 180
        Azimuth angle of the module surface.
        North=0, East=90, South=180, West=270.

    **kwargs
        Passed to Array. Or copy remainder of Array doc string to be explicit.
    """


# could be in pvsystem.py (module is gradually becoming just the objects) or could be in tracking.py
class SingleAxisTrackerArray(BaseArray)
    """
    Parameters
    ----------
    axis_tilt : float, default 0
        The tilt of the axis of rotation (i.e, the y-axis defined by
        axis_azimuth) with respect to horizontal, in decimal degrees.

    etc.

    **kwargs
        Passed to Array. Or copy remainder of Array doc string to be explicit.
    """
```

I believe the only major challenge is that the `get_aoi` and `get_irradiance` methods would either need to differ in signature (as they do now, and thus present a challenge to a `PVSystem` wrapper) or in implementation (tracker methods would include a call to `singleaxis`, and thus would be less efficient in some workflows). @wfvining suggests that the consistent signature is more important and I'm inclined to agree.

We'd also deprecate the old `SingleAxisTracking` class.

We should resolve this issue before releasing the new Array code into the wild in 0.9.
