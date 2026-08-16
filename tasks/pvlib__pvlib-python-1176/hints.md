I like the idea of depreciating the `SingleAxisTracking` class and wrapping tracking functionality more directly into `PVSystem` and `Array`. I don't quite picture yet how it would work on the user side. They can directly create a `SingleAxisTrackerArray` and then pass that to a `PVSystem`? Or create a `FixedTiltArray` and pass that? 

I think we should keep in mind though that when you have a tracking system you are probably very likely going to have a uniform system and a single `Array` per `PVsystem`. So if I am going to create a tracking PVSystem, I am likely going to want to create it straight from a `PVSystem` as the most direct route rather than having to create the array first. (Unless the intent is to depreciate that functionality eventually and push always creating an `Array` first).  In that sense, keeping `SingleAxisTracker` as a `PVSystem` class and just having it create a `SingleAxisTrackingArray` instead of a `Array` may be more user friendly. But I do think there is opportunity to come up with a system to wrap everything together better. 

I also like the simplicity of `Array` and `PVsystem`, and worry about now adding different types of `Array`. 

Just throwing this out there, what if `Array` had a `tracking_model` attribute that right now could be either `fixed` or `single_axis`? Depending on what is passed it sets the appropriate `get_iam` and `get_irradiance` methods, and initiates the appropriate default attributes (`surface_tilt`, `surface_azimuth`, `axis_angle`, `max_angle` etc)? 
> They can directly create a SingleAxisTrackerArray and then pass that to a PVSystem? Or create a FixedTiltArray and pass that?

Yes.

> I think we should keep in mind though that when you have a tracking system you are probably very likely going to have a uniform system and a single Array per PVsystem. 

True. The main application that I can see for mixing a `SingleAxisTrackerArray` with something else is for modeling systems with a mix of broken and working trackers, so it would look something like:

```python
other_params = {}  # module_parameters, etc
PVSystem([
    Array(surface_tilt=45, surface_azimuth=90, **other_params), 
    SingleAxisTrackerArray(**other_params)
])
```

> So if I am going to create a tracking PVSystem, I am likely going to want to create it straight from a PVSystem as the most direct route rather than having to create the array first. (Unless the intent is to depreciate that functionality eventually and push always creating an Array first). In that sense, keeping SingleAxisTracker as a PVSystem class and just having it create a SingleAxisTrackingArray instead of a Array may be more user friendly. 

We discussed deprecating that functionality but haven't committed to it. 

> Just throwing this out there, what if Array had a tracking_model attribute that right now could be either fixed or single_axis? Depending on what is passed it sets the appropriate get_iam and get_irradiance methods, and initiates the appropriate default attributes (surface_tilt, surface_azimuth, axis_angle, max_angle etc)?

Interesting idea. I could see this working at the `PVSystem` level so that you can retain the ability to create the system with a single function call despite the removal of `SingleAxisTracker`.