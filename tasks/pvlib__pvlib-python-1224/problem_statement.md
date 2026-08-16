It should be impossible to instantiate a PVSystem with no Arrays
**Describe the bug**
It should be impossible to instantiate a `PVSystem` with no `Arrays`. Currently this is possible via `PVSystem(arrays=[])`.

**To Reproduce**
Steps to reproduce the behavior:
```python
from pvlib import pvsystem
pvsystem.PVSystem(arrays=[])
```
results in this PVSystem:
```
PVSystem:
  name: None
  inverter: None
```
**Expected behavior**
A `ValueError` should be raised indicating that a PVSystem must have at least one `Array` and suggesting that a system with an arbitrary default array can be constructed by passing `arrays=None` or not passing the `arrays` parameter at all.

**Versions:**
 - ``pvlib.__version__``: 0.8.1+


