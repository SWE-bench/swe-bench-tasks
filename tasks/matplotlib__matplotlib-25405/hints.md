Hi all, any thoughts on this? This is causing breaking behavior in a downstream application, and it'd be helpful to know whether Matplotlib maintainers think a fix will be quick, or if I should invest resources in working around this.
I think we would accept a fix if one were forthcoming.  I suspect the is in the range where we tick every two decades and that is clashing with subs. 
If you pan the "bad" example up or down you can make the ticks show up.  They seem to alternate in and out based on the limits (not just the range) if you zoom out further they never appear.

There is clearly something very wrong in the logic of what `sub` does, but looking at the code I can not quickly understand it...

I'm labeling this as "good first issue" as I think the bug is clear (we should never not have tick labels!) but "hard" because the logic in the tick_values method is a bit convoluted (for a bunch of reasons, some historical, some because we are using the same code for major and minor ticks, some because people have very strong views about what log tick "should" be that are very conditional on the values involved).  Any changes will have to be very careful about unintended consequences and understanding why the code was the way it was (likely will require some git/github archaeology)  and adding a bunch more tests.


Also milestoning for 3.7 as we need to fix this, but I doubt (but we should check) that this is a regression in 3.6 and expect the fix to be somewhat high-risk so we should not backport it.  If I am wrong about either of those, then we can re-milestone and backport.
In `ticker.py`, as the difference between vmin and vmax increases, numdec increases and thus makes stride to be greater than 1 (in the else condition).
> 
            stride = (max(math.ceil(numdec / (numticks - 1)), 1)
                  if mpl.rcParams['_internal.classic_mode'] else
                  (numdec + 1) // numticks + 1)

In the case of stride > 1, ticklocs gets assigned a blank array which I believe to be the root of the problem.
> 
        if hasattr(self, '_transform'):
            ticklocs = self._transform.inverted().transform(decades)
            if have_subs:
                if stride == 1:
                    ticklocs = np.ravel(np.outer(subs, ticklocs))
                else:
                    # No ticklocs if we have >1 decade between major ticks.
                    ticklocs = np.array([])


The ticks appearing upon panning may be explained by `numticks` increasing due to staggering and thus stride being reduced to 1 again, as upon plotting the bad plot for `x = np.arange(10)` even panning does not make the ticks appear.

Hope this helps. I would be glad to help fix this if you could guide me a little. Thanks
I would like to tackle this. Does matplotlib assign issues or is it open for anyone to attempt to fix and submit pull requests?
@Abitamim we do not typically assign issues (sometimes core maintainers will self-assign as a reminder to themselves)

For more info see https://matplotlib.org/stable/devel/contributing.html#issues-for-new-contributors
Hi all, any thoughts on this? This is causing breaking behavior in a downstream application, and it'd be helpful to know whether Matplotlib maintainers think a fix will be quick, or if I should invest resources in working around this.
I think we would accept a fix if one were forthcoming.  I suspect the is in the range where we tick every two decades and that is clashing with subs. 
If you pan the "bad" example up or down you can make the ticks show up.  They seem to alternate in and out based on the limits (not just the range) if you zoom out further they never appear.

There is clearly something very wrong in the logic of what `sub` does, but looking at the code I can not quickly understand it...

I'm labeling this as "good first issue" as I think the bug is clear (we should never not have tick labels!) but "hard" because the logic in the tick_values method is a bit convoluted (for a bunch of reasons, some historical, some because we are using the same code for major and minor ticks, some because people have very strong views about what log tick "should" be that are very conditional on the values involved).  Any changes will have to be very careful about unintended consequences and understanding why the code was the way it was (likely will require some git/github archaeology)  and adding a bunch more tests.


Also milestoning for 3.7 as we need to fix this, but I doubt (but we should check) that this is a regression in 3.6 and expect the fix to be somewhat high-risk so we should not backport it.  If I am wrong about either of those, then we can re-milestone and backport.
In `ticker.py`, as the difference between vmin and vmax increases, numdec increases and thus makes stride to be greater than 1 (in the else condition).
> 
            stride = (max(math.ceil(numdec / (numticks - 1)), 1)
                  if mpl.rcParams['_internal.classic_mode'] else
                  (numdec + 1) // numticks + 1)

In the case of stride > 1, ticklocs gets assigned a blank array which I believe to be the root of the problem.
> 
        if hasattr(self, '_transform'):
            ticklocs = self._transform.inverted().transform(decades)
            if have_subs:
                if stride == 1:
                    ticklocs = np.ravel(np.outer(subs, ticklocs))
                else:
                    # No ticklocs if we have >1 decade between major ticks.
                    ticklocs = np.array([])


The ticks appearing upon panning may be explained by `numticks` increasing due to staggering and thus stride being reduced to 1 again, as upon plotting the bad plot for `x = np.arange(10)` even panning does not make the ticks appear.

Hope this helps. I would be glad to help fix this if you could guide me a little. Thanks
I would like to tackle this. Does matplotlib assign issues or is it open for anyone to attempt to fix and submit pull requests?
@Abitamim we do not typically assign issues (sometimes core maintainers will self-assign as a reminder to themselves)

For more info see https://matplotlib.org/stable/devel/contributing.html#issues-for-new-contributors