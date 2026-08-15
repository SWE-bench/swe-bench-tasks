> you have to fake it by setting C in LogisticRegression to a large number

What's the problem with that approach?

I assumed that it's inexact and slower than a direct implementation of unpenalized logistic regression. Am I wrong?

I notice that setting `C` too high, as in the following, will cause `LogisticRegression.fit` to hang. But I don't know if this is a bug or just an inherent property of the algorithm and its implementation on a 64-bit computer.

``` python
import numpy as np
from sklearn.linear_model import LogisticRegression

x = np.matrix([0, 0, 0, 0,  1, 1, 1, 1]).T
y =           [1, 0, 0, 0,  1, 1, 1, 0]

m = LogisticRegression(C = 1e200)
m.fit(x, y)
print m.intercept_, m.coef_
```

> I notice that setting C too high, as in the following, will cause LogisticRegression.fit to hang

Yes this is to be expected as the problem becomes ill-posed when C is large. Iterative solvers are slow with ill-posed problems.

In your example, the algorithm takes forever to reach the desired tolerance. You either need to increase `tol` or hardcode `max_iter`.

@mblondel is there an alternative to "iterative solvers"?
You won't get exactly the unregularized option, right?

@Kodiologist why do you want this?

You're asking why would I want to do logistic regression without regularization? Because (1) sometimes the sample is large enough in proportion to the number of features that regularization won't buy one anything and (2) sometimes the best-fitting coefficients are of interest, as opposed to maximizing predictive accuracy.

Yes, that was my question.

(1) is not true. It will always buy you a faster solver.

(2) is more in the realms of statistical analysis, which is not really the focus of scikit-learn. I guess we could add this but I don't know what solver we would use. As a non-statistician, I wonder what good any coefficients are that change with a bit of regularization.

I can't say much about (1) since computation isn't my forte. For (2), I am a data analyst with a background in statistics. I know that scikit-learn focuses on traditional machine learning, but it is in my opinion the best Python package for data analysis right now, and I think it will benefit from not limiting itself _too_ much. (I also think, following Larry Wasserman and Andrew Gelman, that statistics and machine learning would mutually benefit from intermingling more, but I guess that's its own can of worms.) All coefficients will change with regularization; that's what regularization does.

I'm not opposed to adding a solver without regularization. We can check what would be good, or just bail and use l-bfgs and check before-hand if it's ill-conditioned?

Yes, all coefficients change with regularization. I'm just honestly curious what you want to do with them afterwards.

Hey,
What is the status on this topic? I'd be really interested in an unpenalized Logistic Regression. This way p-values will mean something statistically speaking. Otherwise I will have to continue using R 😢 for such use cases...
Thanks,
Alex
Or statsmodels?

What solvers do you suggest to implement? How would that be different from the solvers we already have with C -> infty ?
> What solvers do you suggest to implement? How would that be different from the solvers we already have with C -> infty ?

You could try looking at R or statsmodels for ideas. I'm not familiar with their methods, but they're reasonably fast and use no regularization at all.
Yeah statsmodels does the job too if you use the QR algorithm for matrix inversion. My use case is around model interpretability. For performance, I would definitely use regularization. 
I don't think we need to add any new solver... Logistic regression doesn't enjoy a closed form solution, which means that statsmodel must use an iterative solver of some kind too (my guess would be iterative reweighted least squares, but I haven't checked). Setting `C=np.inf` (or equivalently [alpha=0](https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/linear_model/logistic.py#L748)) should in principle work with our current solvers. My recommendation would be to switch to the L-BFGS or Newton-CG solver, since liblinear can indeed be very slow in this setting. Perhaps we can add a `solver="auto"` option and automatically switch to one of these when  `C=np.inf` or equivalently `penalty="none"`?
we're changing the default solver to lbfgs in #10001 fwiw

For the folks that really want unregularised logistic regression (like myself). I've been having to settle with using statsmodels and making a wrapper class that mimics SKLearn API. 
Any updates on this?  This is a big blocker for my willingness to recommend scikit-learn to people.  It's also [not at all obvious](https://www.reddit.com/r/datascience/comments/8kne2r/different_coefficients_scikitlearn_vs_statsmodels/) to people coming from other libraries that scikit-learn does regularization by default and that there's no way to disable it.
@shermstats suggestions how to improve the documentation on that? I agree that it might not be very obvious.
Does l-bfgs allow ``C=np.inf``?
You can specify ``C=np.inf``, though it'll give you the same result as ``C=large value``. On the example I tried, it gave a better fit than statsmodel and statsmodel failed to converge with most other random seeds:

```python
from sklearn.datasets import make_classification
from sklearn.linear_model import LogisticRegression
import statsmodels.api as sm

X, y = make_classification(random_state=2)
lr = LogisticRegression(C=np.inf, solver='lbfgs').fit(X, y)


logit = sm.Logit(y, X)
res = logit.fit()
```

```
Optimization terminated successfully.
         Current function value: 0.167162
         Iterations 10
```

```python
from sklearn.metrics import log_loss
log_loss(y, lr.predict_proba(X))
log_loss(y, res.predict(X))
```
```
0.16197793224715606
0.16716164149746823
```


So I would argue we should just document that you can get an unpenalized model by setting C large or to np.inf.
I'd suggest adding to the docstring and the user guide
"The LogisticRegregression model is penalized by default. You can obtain an unpenalized model by setting C=np.inf and solver='lbfgs'."
> it gave a better fit than statsmodel and statsmodel failed to converge with most other random seeds

R's `glm` is more mature and may make for a better comparison.

> I'd suggest adding to the docstring and the user guide
"The LogisticRegregression model is penalized by default. You can obtain an unpenalized model by setting C=np.inf and solver='lbfgs'."

Why not add allow `penalty = "none"` a la `SGDClassifier`?
@Kodiologist I'm not opposed to adding ``penalty="none"`` but I'm not sure what the benefit is to adding a redundant option.
And I think we'd welcome comparisons to glm. I'm not very familiar with glm so I'm probably not a good person to perform the comparison. However, we are optimizing the log-loss so there should really be no difference. Maybe they implement different solvers so having a benchmark would be nice.
> I'm not opposed to adding `penalty="none"` but I'm not sure what the benefit is to adding a redundant option.

1. It becomes clearer how to get an unpenalized model.
2. It becomes clearer to the reader what code that's using an unpenalized model is trying to do.
3. It allows sklearn to change its implementation of unregularized models in the future without breaking people's code.
If you feel it adds to discoverability then we can add it, and 3 is a valid point (though we can actually not really change that without deprecations probably, see current change of the solver).
Do you want to send a PR?
I don't have the round tuits for it; sorry.
@Kodiologist at least you taught me an idiom I didn't know about ;)
So open for contributors: add ``penalty='none'`` as an option. Also possibly check what solvers support this / are efficient with this (liblinear is probably not) and restrict to those solvers.
> I'd suggest adding to the docstring and the user guide
> "The LogisticRegregression model is penalized by default. You can obtain an unpenalized model by setting C=np.inf and solver='lbfgs'."

This sounds reasonable to me.  I'd also suggest bolding the first sentence because it's legitimately that surprising for people coming from other machine learning or data analysis environments.
@shermstats So @Kodiologist suggested adding ``penalty="none"`` to make it more explicit, which would just be an alias for ``C=np.inf``. It makes sense for me to make this more explicit in this way. Do you have thoughts on that?
Then that would be what's in the documentation. And I agree that bold might be a good idea.
I think for someone with a ML background this is (maybe?) expected, for someone with a stats background, this is seems very surprising.
Exactly!  I have a stats background and have worked with many statistics people coming from R or even point and click interfaces, and this behavior is very surprising to us.  I think for now that `penalty=None` (not sure about `"none"` vs. `None`) is a good solution.  In the future, we should have a separate solver that's called automatically for unpenalized logistic regression to prevent the issues that @mblondel described.
Sorry, which issue do you mean? We're switching to l-bfgs by default, and we can also  internally switch the solver to l-bfgs automatically if someone specifies ``penalty='none'`` (often None is a special token we use for deprecated parameters, but we have stopped doing that. Still 'none' would be more consistent with the rest of the library).
We need ``solver="auto"`` anyway so changing the solver based on the penalty shouldn't be an issue.
[This issue](https://github.com/scikit-learn/scikit-learn/issues/6738#issuecomment-216245049), which refers to the iterative algorithm becoming very slow for large C.  I'm not a numerical analysis expert, but if l-bfgs prevents it from slowing down then that sounds like the right solution.  `penalty='none'` also sounds like the right way to handle this.
@shermstats yes, with l-bfgs this doesn't seem to be an issue. I haven't run extensive benchmarks, though, and won't have time to. If anyone wants to run benchmarks, that would be a great help.