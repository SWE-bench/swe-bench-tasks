It actually sounds like the problem is not the number of bins, but that
bins should be constructed to reflect the distribution, rather than the
range, of the input. I think we should still use n_bins as the primary
parameter, but allow those bins to be quantile based, providing a strategy
option for discretisation (
https://scikit-learn.org/stable/auto_examples/preprocessing/plot_discretization_strategies.html
).

My only question is whether this is still true to the meaning of
"calibration curve" / "reliability curve"

Quantile bins seem a good default here...

Yup, quantile bins would have my desired effect. I just thought it would be nice to allow more flexibility by allowing a `bins` parameter, but I suppose it's not necessary.

I think this still satisfies "calibration curve." I don't see any reason that a "calibration" needs to have evenly-spaced bins. Often it's natural to do things in a log-spaced manner.
I'm happy to see a pr for quantiles here
Sweet. I'll plan to do work on it next weekend