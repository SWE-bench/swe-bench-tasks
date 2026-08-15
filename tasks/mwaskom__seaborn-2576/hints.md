Worth noting: the y axes are not shared in the "wrong" plot, however the y axis autoscaling is off.

My suspicion is that this line is the culprit: https://github.com/mwaskom/seaborn/blob/master/seaborn/regression.py#L611-L616
"the y axes are not shared in the "wrong" plot"

You are right, the scales aren't actually identical. I didn't notice that.
It's fortunate as it makes the workaround (setting the ylim explicitly) a lot easier to accomplish than "unsharing" the axes, which is pretty difficult in matplotlib IIRC.
Worth noting: the y axes are not shared in the "wrong" plot, however the y axis autoscaling is off.

My suspicion is that this line is the culprit: https://github.com/mwaskom/seaborn/blob/master/seaborn/regression.py#L611-L616
"the y axes are not shared in the "wrong" plot"

You are right, the scales aren't actually identical. I didn't notice that.
It's fortunate as it makes the workaround (setting the ylim explicitly) a lot easier to accomplish than "unsharing" the axes, which is pretty difficult in matplotlib IIRC.
What should really happen is that `lmplot` should accept a `facet_kws` dictionary that it passes to `FacetGrid` to set it up. Also then some of the parameters of lmplot that are passed directly should be deprecated with the instruction that they should be packaged in `facet_kws` (not all of them, but less-often-used ones).

Unfortunately I have not been especially consistent across the figure-level functions with which `FacetGrid` parameters do or do not end up i the figure-level function signature. This would probably be good to standardize, but that might involve a lot of annoying deprecation.