Thanks for the very helpful bug report.  

This came in #20161.  @timhoffm any ideas here?
(I don't know if this should block 3.4.3, but if it can be fixed it likely should be).  
The relevant bit of the change is [here](https://github.com/matplotlib/matplotlib/commit/2b8590c8e716bdd87e2b37801063deb7185993e8#diff-04227e6d4900298b309bddab2e848da8cc638da2913c64b5dcf0d800ba2a0c16L810-R823). Clearing the tick keyword dictionaries drops the settings for which sides the ticks should be visible.

This is because, for some reason, the tick `rcParams` are applied at the end of `Axes.__init__` instead of at the end of `Axes.clear` or even `Axis.clear`.