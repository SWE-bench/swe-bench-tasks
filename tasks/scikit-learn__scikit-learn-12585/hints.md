I'm not certain that we want to support this case: why do you want it to be
a class? Why do you want it to be a parameter? Why is this better as a
wrapper than a mixin?

The idea is the following: Suppose we have some

    Estimator(param1=None, param2=None)

that implements `fit` and `predict` and has a fitted attribute `result_` 

Now the wrapper, providing some compatibility methods, is constructed as

    EstimatorWrapper(estimator=Estimator, param1=None, param2=None)

This wrapper, apart from the `estimator` parameter, behaves exactly like the original `Estimator` class, i.e. it has the attributes `param1` and `param2`, calls `Estimator.fit` and `Estimator.predict` and, when fitted, also has the attribute `result_`. 

The reason I want to store the `estimator` as its class is to make it clear to the user that any parameter changes are to be done on the wrapper and not on the wrapped estimator. The latter should only be constructed "on demand" when one of its methods is called.

I actually do provide a mixin mechanism, but the problem is that each sklearn estimator would then need a dedicated class that subclasses both the original estimator and the mixin (actually, multiple mixins, one for each estimator method). In the long term, I plan to replicate all sklearn estimators in this manner so they can be used as drop-in replacements when imported from my package, but for now it's a lot easier to use a wrapper (also for user-defined estimators).  

Now I'm not an expert in python OOP, so I don't claim this is the best way to do it, but it has worked for me quite well so far.

I do understand that you would not want to support a fringe case like this, regarding the potential for user error when classes and instances are both allowed as parameters. In that case, I think that `clone` should at least be more verbose about why it fails when trying to clone classes.
I'll have to think about this more another time.

I don't have any good reason to reject cloning classes, TBH...
I think it's actually a bug in ``clone``: our test for whether something is an estimator is too loose. If we check that it's an instance in the same "if", does that solve the problem?
We need to support non-estimators with get_params, such as Kernel, so
`isinstance(obj, BaseEstimator)` is not appropriate, but `not
isinstance(obj, type)` might be. Alternatively can check if
`inspect.ismethod(obj.get_params)`
