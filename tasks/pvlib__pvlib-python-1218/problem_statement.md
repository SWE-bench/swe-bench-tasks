change eta_m to module_efficiency
`temperature.noct_sam` uses `eta_m_ref` to describe the module efficiency at reference conditions and `temperature.pvsyst_cell` uses `eta_m` to describe the module efficiency generically.

Just calling both of these `module_efficiency` would make the function signatures easily understandable by many more people. I'd be ok with `module_efficiency_ref` but I don't think that precision is very important.

I skimmed [pvterms](https://duramat.github.io/pv-terms/) and didn't see a suggestion for this quantity.

`temperature.noct_sam` has not yet been released and it's just a positional argument, so changing the name is trivial. `temperature.pvsyst_cell` would need a deprecation cycle.

Originally discussed in https://github.com/pvlib/pvlib-python/pull/1177#discussion_r589081257

Assignment of milestone indicates that we will act on this or close it forever before 0.9 is released.

