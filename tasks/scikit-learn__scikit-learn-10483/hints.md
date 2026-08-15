> modules on the basis of how they work rather than function

I don't like this (even though we've done that in the past - inconsistently. Why is LDA and LinearSVC not in linear models?)

I'm +.5 for ``sklearn.impute``, possibly moving when when we add the next class (KNNImputer I guess?).
Actually, given that MICE is not that far away, should be +1
MICE is not far away at all. `sklearn.impute` would be useful, but importing it would conceivably import `neighbors`, `linear_model`, `ensemble` and `tree` if we had implementations of MICE, KNN and forest-based imputation there. We have decidedly scattered anomaly detection around the place. I am uncomfortable about putting MICE and KNNImputer in preprocessing, but I'm not *entirely* certain that sklearn.impute is the right solution.

If we make sklearn.impute, do we rename Imputer to `sklearn.impute.BasicImputer` or `FeaturewiseImputer` or some such?
Of course we could just make KNNImputer live under neighbors and MICE live under ?ensemble.

I've wondered whether in some ways it would make sense to have a pseudo-module sklearn.classifiers, sklearn.regressors, sklearn.imputers, etc, that import from the relevant implementation locations...
Yeah... I would prefer a semantic organization, but it's not how we have done things in the past. I guess you suggest having that in parallel to the current structure? I wouldn't be opposed, but it's a big change. Is the goal to keep two places to import from long-term? That seems slightly confusing....
it's not entirely true that we haven't done semantic organisation in the
past, sklearn.cluster,decomposition,manifold...

On 9 Dec 2017 5:59 am, "Andreas Mueller" <notifications@github.com> wrote:

> Yeah... I would prefer a semantic organization, but it's not how we have
> done things in the past. I guess you suggest having that in parallel to the
> current structure? I wouldn't be opposed, but it's a big change. Is the
> goal to keep two places to import from long-term? That seems slightly
> confusing....
>
> —
> You are receiving this because you authored the thread.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/9726#issuecomment-350343951>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz6yLh_frd5DWue1XE_rdsyqIfjCXoks5s-YbzgaJpZM4PSgEV>
> .
>

True, we have done a really weird mix. The fact that we have ``SGDClassifier`` which implements many losses, and ``LogisticRegression`` which implements many solvers shows that we're not the best with the consistency ;)
but for the users it's moot, as long as they can find stuff.

The MissingnessIndicator (#8075) should also live in this module, which may help users.
I'd like another opinion, but I think this should happen. Make sklearn.impute and move Imputer and all the open imputation-related PRs to this module.
I've opened this to contributors. Please
* copy `sklearn/preprocessing/imputation.py` to `sklearn/impute.py`, as well as the corresponding tests,
* deprecate `Imputer` in  `sklearn/preprocessing/imputation.py` to be removed in v0.22
* create a `sklearn.impute` section in `doc/modules/classes.rst`
* update the deprecated section at the bottom of `doc/modules/classes.rst`
* update `sklearn/__init__.py`'s `__all__`
* move imputation documentation from `doc/modules/preprocessing.rst` to `doc/modules/impute.rst`
* we might also want to rename Imputer in the new module to `SimpleImputer`, `DummyImputer` or something (ideas??)
* update any references to Imputer (in sklearn/, doc/ or examples/) to refer to the new location

and after merge, please advise contributors at #8075, #8478, #9212 to move their work to the new module.
Re: naming, I like `ConstantImputer` because it fills in all missing values in a feature with a constant, but it might not be clear from the name that is what it's doing. Maybe `BasicImputer` or `NaiveImputer`.
it's comparable to DummyRegressor, but calling it DummyImputer seems
unreasonably disparaging :p

I agree because DummyRegressor is not actually useful for doing work, but the Imputer is quite useful.
@jnothman I can work on this. Thanks for the detailed steps.