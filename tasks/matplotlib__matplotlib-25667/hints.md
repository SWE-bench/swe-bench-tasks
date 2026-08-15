The unit conversion is done here: https://github.com/matplotlib/matplotlib/blob/bff46815c9b6b2300add1ed25f18b3d788b816de/lib/matplotlib/axes/_axes.py#L2392-L2401

However, this seems to be checking the units for width/length which doesn't seem correct - I suspect it should be checking the units for *bottom*/*left*, or perhaps *bottom+height*.