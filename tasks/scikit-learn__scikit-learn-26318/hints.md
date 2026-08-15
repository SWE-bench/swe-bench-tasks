Thanks for submitting an issue @noahgolmant ,

The current documentation is correct:

> When set to True, reuse the solution of the previous call to fit and add more estimators to the ensemble, otherwise, just fit a whole new forest.

but it's lacking a few things. In particular, and I think this is where the confusion comes from, it does not specify that one needs to re-set the `n_estimators` parameter manually before calling fit a second time:

```py
est = RandomForestClassifier(n_estmiators=100)
est.set_params(n_estimators=200, warm_start=True)  # set warm_start and new nr of trees
est.fit(X_train, y_train) # fit additional 100 trees to est
```

Regarding the documentation, I think we just need to link to https://scikit-learn.org/stable/modules/ensemble.html#fitting-additional-weak-learners.


Regarding the OOB computation: let's just remove it if `n_more_estimators == 0` and only do it when `n_more_estimators > 0`. The input data *should* be the same anyway (using warm-start with different data makes no sense), so computing the OOB again won't change its value, but it's unnecessary.
Can I work on this issue?
@yashasvimisra2798 sure, thanks! 
Hi @cmarmo , I am a beginner and I would like to help 
@ryuusama09 , welcome! If you are willing to work on this issue please have a careful look to @NicolasHug [comment](https://github.com/scikit-learn/scikit-learn/issues/20435#issuecomment-872835169).
Also, in the [contributor guide](https://scikit-learn.org/dev/developers/contributing.html#contributing-code) you will find all the information you need to start contributing.
I'm ready to solve this issue if no one has yet started working on it
@NicolasHug could you please tell me what are the exact changes you are expecting?