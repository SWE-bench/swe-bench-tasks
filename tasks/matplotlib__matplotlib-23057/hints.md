On the bright side, there is a very easy fix, an explicit call to `ion` (aka `plt.ion` aka `matplotlib.pyplot.ion()`) will fix the behavior.

I suspect that this is more fallout from deferring actually loading the backend until it is actually needed. 
@ahesford Thank you for reporting this and sorry we broke this.

Please forgive my last message if it came across as too terse.
No worries. I'm glad there's a simple workaround. In the meantime, I reverted the version shipped in Void pending a release with a permanent fix.
I'm not really sure how the backend solution works with the `--pylab=tk` switch, but it seems like a solution would be to do `ion` as part of that as the backend is actually selected then.
I can confirm that `ion` resolves the issue. Should IPython assume responsibility for activating interactive mode when importing matplotlib, or should matplotlib attempt to figure out whether to enable interactive mode by default by some suitable means?
This is something that has historically been done by IPython (it is a side effect of `--pylab` (who's use is discouraged but we are never going to deprecate it)).  However, with #22005 we delayed resolving and configuring the backend until it is _actually_ needed (which is the first time you create a Figure, could actually be pushed back to "first time you show a figure", but that is off in  https://github.com/matplotlib/mpl-gui land).

There is something going wrong in the (brittle) dance between IPython and Matplotlib.  Given that it is as change on the mpl side that broke this I assume it it our fault and can (and should) fix it, but we still need to sort out _why_ which will likely require chasing through the code on both sides.  It is complicated because both side have extensive "work with old versions of the other" code.

Related, I observed in some cases at NSLS-II that if we had `pylab = auto` in the IPython config files we saw a similar issue (it was a bit worse, the input hook did not get installed 😱 ) and this was with earlier version of the 3.5 series. 
I am also experiencing this, and `plt.ion()` fixed it for me. Thanks for the suggestion @tacaswell!

It would be nice if this line was not necessary as I will have to update all of my notebooks!