Consider extracting the surface orientation calculation in pvlib.tracking.singleaxis() to its own function
**Is your feature request related to a problem? Please describe.**
The usual workflow for modeling single-axis tracking in pvlib is to treat tracker rotation (`tracker_theta`) as an unknown to be calculated from solar position and array geometry.  However, sometimes a user might have their own tracker rotations but not have the corresponding `surface_tilt` and `surface_azimuth` values.  Here are a few motivating examples:
- Using measured rotation angles
- Post-processing the output of `tracking.singleaxis()` to include wind stow events or tracker stalls
- Other tracking algorithms that determine rotation differently from the astronomical method

Assuming I have my tracker rotations already in hand, getting the corresponding `surface_tilt` and `surface_azimuth` angles is not as easy as it should be.  For the specific case of horizontal N-S axis the math isn't so bad, but either way it's annoying to have to DIY when pvlib already has code to calculate those angles from tracker rotation.

**Describe the solution you'd like**
A function `pvlib.tracking.rotation_to_orientation` that implements the same math in `pvlib.tracking.singleaxis` to go from `tracker_theta` to `surface_tilt` and `surface_azimuth`.  Basically extract out the second half of `tracking.singleaxis` into a new function.  Suggestions for the function name are welcome.  To be explicit, this is more or less what I'm imagining:

```python
def rotation_to_orientation(tracker_theta, axis_tilt=0, axis_azimuth=0, max_angle=90):
    # insert math from second half of tracking.singleaxis() here
    out = {'tracker_theta': tracker_theta, 'aoi': aoi,
           'surface_tilt': surface_tilt, 'surface_azimuth': surface_azimuth}
    return pandas_if_needed(out)
```

**Describe alternatives you've considered**
Continue suffering

**Additional context**
This is one step towards a broader goal I have for `pvlib.tracking` to house other methods to determine tracker rotation in addition to the current astronomical method, the same way we have multiple temperature and transposition models.  These functions would be responsible for determining tracker rotations, and they'd all use this `rotation_to_orientation` function to convert rotation to module orientation.

Separately, I wonder if the code could be simplified using the tilt and azimuth equations in Bill's technical report (https://www.nrel.gov/docs/fy13osti/58891.pdf) -- seems like what we're doing is overly complicated, although maybe I've just not studied it closely enough.

cc @williamhobbs @spaneja 
