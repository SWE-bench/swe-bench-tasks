This was a purposeful change in #10033.  However, it should have had an API change entry - our apologies.  

I'm also not sure that your use case should error.  I think we need to still think about all the sharing/datalim interactions to make sure we always do the right thing....  ping @efiring 
This combination is internally consistent only in the special case where all shared Axes have identical box aspect ratios in screen space.  This is a common case, but by no means universal.  Rather than blocking datalim at the outset, it might be possible to check for the consistency condition in `apply_aspect`.  If it is met, then `apply_aspect` *might* be able to proceed as if there were no sharing.  But it can get very complicated, because axes A and B might share both x and y, but C might share only x, etc.

I'm not sure it is worth trying to untangle this web in order to relax the simple blanket restriction against combining sharing of both axes with adjustable datalim.  Maybe the only sensible step in that direction would be to handle the single special case in which *all* sharing involves *both* x and y in a set of Axes in a single Figure.

Or maybe `apply_aspect` can be replaced with something based on a general constraint solver, which could raise an exception whenever it runs into a conflict.
I have the same problem as @nbud. It is fairly common to have say a 2x2 grid of images displayed via imshow and you want to preserve the x-y scale after a zoom event say (e.g. R,G,B in three panels then RGB in the fourth). I'll switch back for 2.0.2 in the mean time.
Have you considered using `adjustable='box'`?
matplotlib 1.5.3 and 2.2.2 seem in conflict over this, or maybe I just don't understand which way to go.

I'm updating a codebase from matplotlib 1.5.3 to 2.2.2. `adjustable='box-forced'` is no longer defined so I switched to `'box'`:

    fig, axesList = plt.subplots(n_generation, sharey=True, sharex=True,
        subplot_kw={'aspect': 0.4, 'adjustable': 'box'})

That works in matplotlib 2.2.2 but matplotlib 1.5.3 raises:

    ValueError: adjustable must be "datalim" for shared axes

It'd be good for the new code to pass our Jenkins build before I merge in the change and update the shared pyenv to the new libraries, so I tried `'datalim'`. Then matplotlib 2.2.2 raises the opposite error:

    RuntimeError: adjustable='datalim' is not allowed when both axes are shared.

I don't see docs on these choices and their compatibility with shared axes.

Matplotlib version

* Operating system: sys.platform = linux2
* Matplotlib version: 2.2.2
* Matplotlib backend: Agg
* Python version: 2.7.15

To me the error here is that `ax.axis('equal')` calls `ax.set_aspect('equal', adjustable='datalim')`.  Why does it do that instead of the default 'box'?  
I think this is just a matter of leaving long-standing behavior in place.  This definition of 'equal' predates the `Axes` refactoring 6 years ago.  (I think it originated in Matlab compatibility.) Most or all of the behavior of `ax.axis()` has been kept unchanged from early days.  There are two arguments that offer variations on 'equal': 'scaled', and 'image'.  Both of those use 'box' adjustable.
Anyhow, the workaround is to call `ax.set_aspect('equal')`.  We should probably deprecate `ax.axis('equal')`, since its hard to see why we need two ways to do the same thing.  But I think this can wait for 3.2...
@timhoffm recently updated the docstring of `axis("equal")` and cohorts in https://github.com/matplotlib/matplotlib/pull/15032. Would that qualify to close this issue, or is there another action item?
#15032 only adds documentation that `ax.axis('equal')` is  `ax.set_aspect('equal', adjustable='datalim')`.

That does not help too much for a user with the above problem because his code does not mention `datalim`. And the error message does not mention aspect/equal. Any idea how to hint at a solution in the error message without assuming too much?
I agree with @timhoffm. I am getting the same error and my code doesn't mention `datalim`
@stormshawn are you using `axis('equal')` instead of `ax.set_aspect('equal')`?  Is there a compelling reason to do so?  