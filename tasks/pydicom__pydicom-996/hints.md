I could reproduce this with a smaller sequence (2MB) under Windows. The memory usage got up until it was about twice the initial value (after a few hundred iterations), after that got back down to the initial value and started to rise again.
If removing the code that sets the parent, this does not happen - the memory remains at the initial value.
So, your assessment about the garbage collection delayed due to cyclic references seems to be correct.
I will have a look how to resolve this - probably later this week.
I'm not seeing any memory leakage using [memory-profiler](https://pypi.org/project/memory-profiler/). What are you using to profile?

I get similar results (~38 MB, no sign of gradual increase) for each of the following branches and Python 3.6.5, current `master`:
```python
import time
from pydicom import dcmread
from pydicom.data import get_testdata_file

fname = get_testdata_file("rtplan.dcm")
branch = 'A'

if branch == 'A':
    for ii in range(1):
        ds = dcmread(fname)
elif branch == 'B':
    for ii in range(1):
        ds = dcmread(fname)
        seq = ds.BeamSequence
elif branch == 'C':
    for ii in range(10000):
        ds = dcmread(fname)
elif branch == 'D':
    for ii in range(10000):
        ds = dcmread(fname)
        seq = ds.BeamSequence
elif branch == 'E':
    for ii in range(10000):
        ds = dcmread(fname)
        seq = ds[0x300a, 0x00b0].value

time.sleep(1)
```
It looks like there's a bit of overhead for ds.BeamSequence but not a lot?
@scaramallion - I didn't use a profiler, just watched the private memory consumption. I can add a screenshot if I get to it tonight. A couple of remarks:
- there is no real leak here, as the memory is freed eventually, just not immediately as with the scenario without setting a parent
- the test data you used is quite small - I used a real rtstruct file for the test with a sequence of about 2MB size, so that is more visible in this case
- not setting the parent didn't fail any test, so while I'm sure there was a scenario where this was not needed, there is no tests for it; I have to check if and when this is really needed
- the solution is not complete anyway, as with the access via `__getitem__` the parent is not set