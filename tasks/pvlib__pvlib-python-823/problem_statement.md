backtracking for rare case when sun below tracker improvement
**Describe the bug**
- related to #656
- in the rare case when the sun rays are below the tracker, then the top of the next row is shaded
- currently tracker backtracks away from sun, back is facing sun instead of front
- this only happens for tilted trackers and very low sun angles, either early morning or late evening when the sun rays are furthest north or south

**To Reproduce**
Steps to reproduce the behavior:
1. create a tilted tracker
```python
# in Brazil so facing north
axis_azimuth = 0.0 
axis_tilt = 20
max_angle = 75.0
gcr = 0.35
```
2. pick the earliest morning (or latest evening) timestamp
```python
import pvlib
import pandas as pd

# Brazil, timezone is UTC-3[hrs]
starttime = '2017-01-01T00:30:00-0300'
stoptime = '2017-12-31T23:59:59-0300'
lat, lon = -27.597300, -48.549610
times = pd.DatetimeIndex(pd.date_range(
    starttime, stoptime, freq='H'))
solpos = pvlib.solarposition.get_solarposition(
    times, lat, lon)
# get the early times
ts0 = '2017-01-01 05:30:00-03:00'
ts1 = '2017-01-01 12:30:00-03:00'
apparent_zenith = solpos['apparent_zenith'][ts0:ts1]
azimuth = solpos['azimuth'][ts0:ts1]
sat = pvlib.tracking.singleaxis(
    apparent_zenith, azimuth, axis_tilt, axis_azimuth, max_angle, True, gcr)
```
3. notice that the tracker suddenly jumps from one side facing east to west
```
                           tracker_theta        aoi  surface_azimuth  surface_tilt
2017-01-01 05:30:00-03:00     -21.964540  62.721237       310.299287     29.368272
2017-01-01 06:30:00-03:00      16.231156  69.264752        40.403367     25.546154
2017-01-01 07:30:00-03:00      69.073645  20.433849        82.548858     70.389280
2017-01-01 08:30:00-03:00      54.554616  18.683626        76.316479     56.978562
2017-01-01 09:30:00-03:00      40.131687  17.224233        67.917292     44.072837
2017-01-01 10:30:00-03:00      25.769332  16.144347        54.683567     32.194782
2017-01-01 11:30:00-03:00      11.439675  15.509532        30.610665     22.923644
2017-01-01 12:30:00-03:00      -2.877428  15.358209       351.639727     20.197537
```

4. AOI is also wrong

**Expected behavior**
The tracker should avoid shade. It should not jump from one direction to the other. If the sun ray is below the tracker then it will need to track to it's max rotation or backtrack. If there is shading at it's max rotation then it should track backtrack to zero, or perhaps parallel to the sun rays. Perhaps if bifacial, then it could go backwards, 180 from the correct backtrack position to show it's backside to the sun.

proposed algorithm (_updated after [this comment](#issuecomment-559154895)_):
```python
if backtracking:
    # cos(R) = L / Lx, R is rotation, L is surface length,
    # Lx is shadow on ground, tracker shades when Lx > x
    # x is row spacing related to GCR, x = L/GCR
    lrot = np.cos(tr_rot_no_lim)  # tracker rotation not limited by max angle

    # Note: if tr_rot > 90[deg] then lrot < 0 
    # which *can* happen at low angles if axis tilt > 0
    # tracker should never backtrack more than 90[deg], when lrot = 0
    cos_rot = np.minimum(np.abs(lrot) / self.gcr, 1)

    # so if lrot<0 tracker should backtrack forward
    # backtrack_rot = np.sign(lrot) * np.arccos(cos_rot)

    # NOTE: updated after comment from @kevinsa5 at Nov 27, 2019, 8:16 AM PST
    # to remove sign()
    backtrack_rot = np.arccos(cos_rot)
```

also remove abs from aoi calculation

https://github.com/pvlib/pvlib-python/blob/c699575cb6857674f0a96348b77e10c805e741c7/pvlib/tracking.py#L461

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Versions:**
 - ``pvlib.__version__``:  0.6.3
 - ``pandas.__version__``:  0.24
 - python: 3.7

**Additional context**
Add any other context about the problem here.

[STY] remove old comments from single axis tracking
**Describe the bug**
After #823 is merged there may be stale comments in `pvlib.tracking.singleaxis` and commented code that can be removed. This might make the code more readable. It would also resolve some stickler complaints about long lines.

**To Reproduce**
Comments to remove:
1. [L375-L379](../blob/e210b8253458a60c95fc21939e9817271cf51934/pvlib/tracking.py#L375-L379) - the tracking algorithm now follows [1] that uses clockwise rotation around z-axis from north
2. [L393-L395](../blob/e210b8253458a60c95fc21939e9817271cf51934/pvlib/tracking.py#L393-L395) - ditto
3. [L400-L410](../blob/e210b8253458a60c95fc21939e9817271cf51934/pvlib/tracking.py#L400-L410) - ditto
4. [L441-L452](../blob/e210b8253458a60c95fc21939e9817271cf51934/pvlib/tracking.py#L441-L452) - pvlib has been using arctan2(x,z) in `pvlib.tracking.singleaxis` for 6 years since 1fb82cc262e43e1d2b55e4b5510a1a5e7e340667, so I believe these comments are unnecessary now
5. [L471-L472](../blob/e210b8253458a60c95fc21939e9817271cf51934/pvlib/tracking.py#L471-L472) - this commented code was updated in #823, should we leave it or delete it?
3. [L553-L555](../blob/e210b8253458a60c95fc21939e9817271cf51934/pvlib/tracking.py#L553-L555)

etc.

[1] https://www.nrel.gov/docs/fy20osti/76626.pdf

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Versions:**
 - ``pvlib.__version__``: 
 - ``pandas.__version__``: 
 - python:

**Additional context**
Add any other context about the problem here.

