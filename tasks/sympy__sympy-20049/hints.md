Hi @moorepants, I think I could fix this. It would be implemented as a part of `ReferenceFrame` in `sympy/physics/vector/frame.py`, right?
No, it is part of Point. There are some nuances here and likely not a trivial PR to tackle. I'd recommend some simpler ones first if you are new to sympy and dynamics.
Sure, understood. Thank you @moorepants .
> No, it is part of Point. There are some nuances here and likely not a trivial PR to tackle. I'd recommend some simpler ones first if you are new to sympy and dynamics.

I would like to work on this issue.

The current Point.vel() returns velocity already defined in a reference frame , it doesn't calculate velocity between two points , so it would require a new function to calculate velocity between two points this would make it fully automatic.

So I propose , a change in vel() function to set  velocity of particle from r and a new function to which calculates and returns velocity by calculating displacement vector , this function wouldn't set the velocity of particle but would return it on being called.
The idea is that if there is sufficient information about the relative position of points, that Point.vel() can determine there is sufficient information and calculate the velocity. You should study how ReferenceFrame does this with ang_vel().
> The idea is that if there is sufficient information about the relative position of points, that Point.vel() can determine there is sufficient information and calculate the velocity. You should study how ReferenceFrame does this with ang_vel().

Okay on it!!