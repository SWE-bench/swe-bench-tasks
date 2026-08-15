@NicolasHug I could give it a try. Furthermore, should `_check_sample_weight` also guarantee non-negativeness and sum(sw) > 0 ?
I think for the above mentioned estimators @NicolasHug intended this as an easier refactoring issues for new contributors, but if you want to look into it feel free to open PRs.

> (I left-out the linear_model module because it seems more involved there)

@lorentzenchr  Your expertise would certainly be appreciated there. As you mention https://github.com/scikit-learn/scikit-learn/issues/15438 there is definitely work to be done on improving `sample_weight` handling consistency in linear models. 

> Furthermore, should _check_sample_weight also guarantee non-negativeness and sum(sw) > 0 ?

There are some use cases when it is useful, see https://github.com/scikit-learn/scikit-learn/issues/12464#issuecomment-433815773 but in most cases it would indeed make sense to error on them. In the linked issues it was suggested maybe to enable this check but then allow it to be disabled with a global flag in `sklearn.set_config`. So adding that global config flag and adding the corresponding check in `_check_sample_weight` could be a separate PR.
> intended this as an easier refactoring issues for new contributors

In that case, I will focus on `_check_sample_weight` and on linear models. So new contributors are still welcome 😃 
Thanks @lorentzenchr .

BTW @rth maybe we should add a `return_ones` parameter to `_check_sample_weights`. It would be more convenient than protecting the call with `if sample_weight is not None:...`
Should sample_weights be made an array in all cases? I feel like we have shortcuts if it's ``None`` often and I don't see why we would introduce a multiplication with a constant array.

Also: negative sample weights used to be allowed in tree-based models, not sure if they still are.
> Should sample_weights be made an array in all cases?

No hence my comment above
Oh sorry didn't see that ;)
@fbchow and I will pick up the fix for BaseDecisionTree for the scikitlearn sprint
@fbchow we will do DBSCAN for the wmlds scikitlearn sprint (pair programming @akeshavan)
working on BaseBagging for the wmlds sprint with Honglu Zhang (@ritalulu)
@mdouriez and I will work on the GaussianNB one
Working on BaseGradientBoosting for wimlds sprint (pair programming @akeshavan)
Working on BaseForest for wimlds sprint (pair programming @lakrish)
often the check is within a ``if sample_weights is not None:`` so we wouldn't need to add an argument