If you use verbose=1 in your snippet, you'll get plenty of ConvergenceWarning.

```py
from sklearn.datasets import load_breast_cancer
from sklearn.linear_model import LogisticRegressionCV

data = load_breast_cancer()
y = data.target
X = data.data

clf = LogisticRegressionCV(verbose=1)
clf.fit(X, y)
print(clf.n_iter_)
```

I am going to close this one, please reopen if  you strongly disagree.
I also think that `LogisticRegression` ~~(and `LogisticRegressionCV`)~~ should print a `ConvergenceWarning` when it fails to converge with default parameters.

 It does not make sense to expect the users to set the verbosity in order to get the warning. Also other methods don't do this:  e.g. MLPClassifier [may raise ConvergenceWarnings](https://github.com/scikit-learn/scikit-learn/blob/de29f3f22db6e017aef9dc77935d8ef43d2d7b44/sklearn/neural_network/tests/test_mlp.py#L70) so does [MultiTaskElasticNet](https://github.com/scikit-learn/scikit-learn/blob/da71b827b8b56bd8305b7fe6c13724c7b5355209/sklearn/linear_model/tests/test_coordinate_descent.py#L407) or [LassoLars](https://github.com/scikit-learn/scikit-learn/blob/34aad31924dc9c8551e6ff8edf4e729dbfc1b973/sklearn/linear_model/tests/test_least_angle.py#L349). 

 The culprit is this [line](https://github.com/scikit-learn/scikit-learn/blob/da71b827b8b56bd8305b7fe6c13724c7b5355209/sklearn/linear_model/logistic.py#L710-L712) that only affects the `lbfgs` solver. This is more critical if we can to make `lbfgs` the default solver https://github.com/scikit-learn/scikit-learn/issues/9997 in `LogisticRegression`
After more thoughts, the case of `LogisticRegressionCV` is more debatable, as there are always CV parameters that may fail to converge and handling it the same way as `GridSearchCV` would be probably more reasonable.

However,
```py
from sklearn.datasets import load_breast_cancer
from sklearn.linear_model import LogisticRegression

data = load_breast_cancer()
y = data.target
X = data.data

clf = LogisticRegression(solver='lbfgs')
clf.fit(X, y)
print(clf.n_iter_)
```
silently fails to converge, and this is a bug IMO. This was also recently relevant in https://github.com/scikit-learn/scikit-learn/issues/10813

A quick git grep seems to confirm that ConvergenceWarning are generally issued when verbose=0, reopening.

The same thing happens for solver='liblinear' (the default solver at the time of writing) by the way (you need to decrease max_iter e.g. set it to 1). There should be a test that checks the ConvergenceWarning for all solvers.
I see that nobody is working on it. Can I do it ?
Sure,  thank you @AlexandreSev 
Unless @oliverangelil was planning to submit a PR..
I think I need to correct also this [line](https://github.com/scikit-learn/scikit-learn/blob/da71b827b8b56bd8305b7fe6c13724c7b5355209/sklearn/linear_model/tests/test_logistic.py#L807). Do you agree ?
Moreover, I just saw that the name of this [function](https://github.com/scikit-learn/scikit-learn/blob/da71b827b8b56bd8305b7fe6c13724c7b5355209/sklearn/linear_model/tests/test_logistic.py#L92) is not perfectly correct, since it does not test the convergence warning.
Maybe we could write a test a bit like this [one](https://github.com/scikit-learn/scikit-learn/blob/da71b827b8b56bd8305b7fe6c13724c7b5355209/sklearn/linear_model/tests/test_logistic.py#L1037) to test all the warnings. What do you think ?
You can reuse test_max_iter indeed to check for all solvers that there has been a warning and add an assert_warns_message in it. If you do that, test_logistic_regression_convergence_warnings is not really needed any more. There is no need to touch test_lr_liblinear_warning.

The best is to open a PR and see how that goes! Not that you have mentioned changing the tests but you will also need to change sklearn/linear_model/logistic.py to make sure a ConvergenceWarning is issued for all the solvers.


yes I think there are a few cases where we only warn if verbose. I'd rather
consistently warn even if verbose=0
