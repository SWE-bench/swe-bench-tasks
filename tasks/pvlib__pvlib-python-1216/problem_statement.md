`pvsystem.calcparams_cec()` does not propagate parameters
**Describe the bug**

The function calls `calcparams_desoto` with hardcoded reference values.

https://github.com/pvlib/pvlib-python/blob/40ba4bd5c8b91754aa73e638ed984ab9657847cd/pvlib/pvsystem.py#L1850-L1855

This means the function is silently ignoring its inputs, yielding incorrect results that may go unnoticed.


**Expected behavior**

The function parameters are propagated into the `calcparams_desoto` call. In particular: `EgRef`, `dEgdT`, `irrad_ref`, `temp_ref`
