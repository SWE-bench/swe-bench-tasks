https://stackoverflow.com/questions/49550656/run-pvlib-modelchain-with-pvwatts-model/50165303#50165303

The work around is to scale your ``module_parameters ['pdc0']``. Pull requests welcome for improving the functionality and/or documentation.
It seems that the system scaling provided by `PVSystem.scale_voltage_current_power()` is a system-level entity that should be included in `PVSystem.sapm()` and `PVSystem.singlediode()` computations, in addition to adding this to `PVSystem.pvwatts_dc()`. Currently, a higher level `ModelChain` function does this (except for pvwatts, as discussed above). If folks agree to this, then a question arises as to if the corresponding wrapped functions in `pvsystem.py` should still only calculate `singlediode()` for a single module/device instead of the whole system. (ATM, I think that they should.)
@cwhanse we need this for SPI. Do you have any concern with adding this

```python
        self.results.dc = self.system.scale_voltage_current_power(
            self.results.dc,
            unwrap=False
        )
```

to 

https://github.com/pvlib/pvlib-python/blob/56971c614e7faea3c24013445f1bf6ffe9943305/pvlib/modelchain.py#L732-L735

?

Or do you think we should go ahead with @markcampanelli's suggestion above? I think @markcampanelli's suggestion is better on the merits but it's a much bigger change and I don't know how to do it in a way that wouldn't cause user code to return unexpected answers.
I don't have a problem patching that into `pvlib.modelchain.ModelChain.pvwatts_dc`. I think it's an oversight that the scaling was left out, since it is included in the `sapm` and `singlediode` methods.
I think we left it out because it's arguably a departure from the pvwatts model in which you're typically specifying the pdc0 of the entire system. But I don't see a problem with the extension within our data model.
want me to open a PR? Or have you got it?
Would be great if you can do it.