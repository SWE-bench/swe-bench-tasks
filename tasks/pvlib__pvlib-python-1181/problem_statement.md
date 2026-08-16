remove ModelChain.orientation_strategy
I don't like that `ModelChain(system, location, orientation_strategy='flat`|`south_at_latitude_tilt`) modifies the `system` object. It's not something we do anywhere else in pvlib. `orientation_strategy` only supports flat and south_at_latitude_tilt, neither of which are commonly used in the real world in 2020. 

I think we should remove it, maybe even without deprecation, in 0.8.

I'm ok with keeping the `modelchain.get_orientation` function for now.
