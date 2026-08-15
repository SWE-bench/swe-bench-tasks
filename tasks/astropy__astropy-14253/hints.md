@mhvk - I basically agree with your assessment as being logical.  I guess the only question is about having an easily stated rule for what happens.  I wonder if we could make a rule (with a corresponding implementation) which is basically: "Any unary operation on a Quantity will preserve the `info` attribute if defined".  So that would put your "real unit changes.." bullet into the "yes" category.

That makes some sense, but I think I'd treat `q * unit` as a binary operation still (even if it isn't quite implemented that way; I do think it would be confusing if there is a difference in behaviour between that and `q * (1*unit)` (note that the implementation already makes a copy of `q`).

Also, "unary" may be too broad: I don't think I'd want `np.sin(q)` to keep the `info` attribute... 

@mhvk - agreed.  My main point is to strive to make the behavior predictable.
