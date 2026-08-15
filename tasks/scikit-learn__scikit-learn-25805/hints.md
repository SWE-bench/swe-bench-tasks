Once we have metadata routing with would have an explicit way to tell how to broadcast such parameters to the base estimators. However as far as I know, the current state of SLEP6 does not have a way to tell whether or not we want to apply cross-validation indexing and therefore disable the length consistency check for the things that are not meant to be the sample-aligned fit params.

Maybe @adrinjalali knows if this topic was already addressed in SLEP6 or not.
I think this is orthogonal to SLEP006, and a bug in `CalibratedClassifierCV`, which has these lines:

https://github.com/scikit-learn/scikit-learn/blob/c991e30c96ace1565604b429de22e36ed6b1e7bd/sklearn/calibration.py#L311-L312

I'm not sure why this check is there. IMO the logic should be like `GridSearchCV`, where we split the data where the length is the same as `y`, otherwise pass unchanged.

cc @glemaitre 
@adrinjalali - Thanks for your response Adrin, this was my conclusion as well. What would be the path forward to resolve this bug?
I'll open a PR to propose a fix @Sidshroff 
I looked at other estimators and indeed we never check that `fit_params` are sample-aligned but only propagate. I could not find the reasoning in the original PR, we were a bit sloppy regarding this aspect. I think a PR removing this check is fine.