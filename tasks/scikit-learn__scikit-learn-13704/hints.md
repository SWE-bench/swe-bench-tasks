On closer inspection this is just caused by floating point error in calculating the variance, and therefore not a bug with sklearn. It is resolvable by setting the variance threshold to e.g. 1e-33 rather than 0.
We should probably avoid 0 as a default. I'd be happy to deprecate the
current default and change it to np.finfo(X.dtype) or something smaller by
default.

Another option would be to use np.ptp rather than np.var when the threshold is 0.