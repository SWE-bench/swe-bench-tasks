This issue has been marked "inactive" because it has been 365 days since the last comment. If this issue is still present in recent Matplotlib releases, or the feature request is still wanted, please leave a comment and this label will be removed. If there are no updates in another 30 days, this issue will be automatically closed, but you are free to re-open or create a new issue if needed. We value issue reports, and this procedure is meant to help us resurface and prioritize issues that have not been addressed yet, not make them disappear.  Thanks for your help!
This is still a bug.  The source of this bug is definitely different than it was before (as we have radically re-done this code).

The issue is that:
 - tight layout tries to run a one-off layout and then un-set the layout manager to make it "stick"
 - if `None` is passed to `fig.set_layout_manager` it falls back to doing what the rcparams say
 - that re-installs a new TightLayout engine with the default parameters

I think the fix is to make the "unset layout manager" more robust.
https://github.com/matplotlib/matplotlib/blob/8ca75e445d136764bbc28d8db7346c261e8c6c41/lib/matplotlib/figure.py#L2573-L2638

and 

https://github.com/matplotlib/matplotlib/blob/8ca75e445d136764bbc28d8db7346c261e8c6c41/lib/matplotlib/figure.py#L3517-L3518

are the badly interacting bits of code.

I think we need a (private) flag to say "make it None, ignore rcparams" (or use rccontext in the `finally`?).
I haven’t followed this whole thread, but if we want to not have a layout engine we can pass `set_layout_engine("none")`.
Ah, then using `'none'` is probably the right thing to do.