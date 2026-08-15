I am interested in contributing. It sounds to me like you want `check_estimator` to verify that there are no properties which are parameter names?

Thanks for wanting to contribute.
I think we want to check that calling `set_params` is equivalent to passing parameters in `__init__`.
Actually, I'm a bit appalled to see that we never test `set_params` at all, it seems.

Can you please double check that with the current common tests the example I gave above passes?
The simplest test I can think of is to add a line to `check_parameters_default_constructible`
that does `estimator.set_params(**estimator.get_params())`. That should fail with the example I gave.
