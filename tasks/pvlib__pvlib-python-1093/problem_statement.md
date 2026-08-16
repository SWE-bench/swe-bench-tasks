ModelChain.prepare_inputs can succeed with missing dhi
From the docstring for `ModelChain.prepare_inputs()` I believe the method should fail if `weather` does not have a `dhi` column.

The validation checks for `'ghi'` twice, but not `'dhi`'

https://github.com/pvlib/pvlib-python/blob/11c356f9a89fc88b4d3ff368ce1aae170a97ebd7/pvlib/modelchain.py#L1136
