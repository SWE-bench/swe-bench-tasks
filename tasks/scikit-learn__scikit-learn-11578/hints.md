Yes, that sounds like a bug. Thanks for the report. A fix and a test is welcome.
> It seems like altering L922 to read
> log_reg = LogisticRegression(fit_intercept=fit_intercept, multi_class=multi_class)
> so that the LogisticRegression() instance supplied to the scoring function at line 955 inherits the multi_class option specified in LogisticRegressionCV() would be a fix, but I am not a coder and would appreciate some expert insight!

Sounds good
Yes, I thought I replied to this. A pull request is very welcome.

On 12 April 2017 at 03:13, Tom Dupré la Tour <notifications@github.com>
wrote:

> It seems like altering L922 to read
> log_reg = LogisticRegression(fit_intercept=fit_intercept,
> multi_class=multi_class)
> so that the LogisticRegression() instance supplied to the scoring function
> at line 955 inherits the multi_class option specified in
> LogisticRegressionCV() would be a fix, but I am not a coder and would
> appreciate some expert insight!
>
> Sounds good
>
> —
> You are receiving this because you commented.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/8720#issuecomment-293333053>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz62ZEqTnYubanTrD-Xl7Elc40WtAsks5ru7TKgaJpZM4M2uJS>
> .
>

I would like to investigate this.
please do 
_log_reg_scoring_path: https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/linear_model/logistic.py#L771
It has a bunch of parameters which can be passed to logistic regression constructor such as "penalty", "dual", "multi_class", etc., but to the constructor passed only fit_intercept on https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/linear_model/logistic.py#L922.

Constructor of LogisticRegression:
`def __init__(self, penalty='l2', dual=False, tol=1e-4, C=1.0,
                 fit_intercept=True, intercept_scaling=1, class_weight=None,
                 random_state=None, solver='liblinear', max_iter=100,
                 multi_class='ovr', verbose=0, warm_start=False, n_jobs=1)`

_log_reg_scoring_path method:
`def _log_reg_scoring_path(X, y, train, test, pos_class=None, Cs=10,
                          scoring=None, fit_intercept=False,
                          max_iter=100, tol=1e-4, class_weight=None,
                          verbose=0, solver='lbfgs', penalty='l2',
                          dual=False, intercept_scaling=1.,
                          multi_class='ovr', random_state=None,
                          max_squared_sum=None, sample_weight=None)`

It can be seen that they have similar parameters with equal default values: penalty, dual, tol, intercept_scaling, class_weight, random_state, max_iter, multi_class, verbose;
and two parameters with different default values: solver, fit_intercept.

As @njiles suggested, adding multi_class as argument when creating logistic regression object, solves the problem for multi_class case.
After that, it seems like parameters from the list above should be passed as arguments to logistic regression constructor.
After searching by patterns and screening the code, I didn't find similar bug in other files.
please submit a PR ideally with a test for correct behaviour of reach
parameter

On 19 Apr 2017 8:39 am, "Shyngys Zhiyenbek" <notifications@github.com>
wrote:

> _log_reg_scoring_path: https://github.com/scikit-learn/scikit-learn/blob/
> master/sklearn/linear_model/logistic.py#L771
> It has a bunch of parameters which can be passed to logistic regression
> constructor such as "penalty", "dual", "multi_class", etc., but to the
> constructor passed only fit_intercept on https://github.com/scikit-
> learn/scikit-learn/blob/master/sklearn/linear_model/logistic.py#L922.
>
> Constructor of LogisticRegression:
> def __init__(self, penalty='l2', dual=False, tol=1e-4, C=1.0,
> fit_intercept=True, intercept_scaling=1, class_weight=None,
> random_state=None, solver='liblinear', max_iter=100, multi_class='ovr',
> verbose=0, warm_start=False, n_jobs=1)
>
> _log_reg_scoring_path method:
> def _log_reg_scoring_path(X, y, train, test, pos_class=None, Cs=10,
> scoring=None, fit_intercept=False, max_iter=100, tol=1e-4,
> class_weight=None, verbose=0, solver='lbfgs', penalty='l2', dual=False,
> intercept_scaling=1., multi_class='ovr', random_state=None,
> max_squared_sum=None, sample_weight=None)
>
> It can be seen that they have similar parameters with equal default
> values: penalty, dual, tol, intercept_scaling, class_weight, random_state,
> max_iter, multi_class, verbose;
> and two parameters with different default values: solver, fit_intercept.
>
> As @njiles <https://github.com/njiles> suggested, adding multi_class as
> argument when creating logistic regression object, solves the problem for
> multi_class case.
> After that, it seems like parameters from the list above should be passed
> as arguments to logistic regression constructor.
> After searching by patterns, I didn't find similar bug in other files.
>
> —
> You are receiving this because you commented.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/8720#issuecomment-295004842>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz677KSfKhFyvk7HMpAwlTosVNJp6Zks5rxTuWgaJpZM4M2uJS>
> .
>

I would like to tackle this during the sprint 

Reading through the code, if I understand correctly `_log_reg_scoring_path` finds the coeffs/intercept for every value of `C` in `Cs`, calling the helper `logistic_regression_path` , and then creates an empty instance of LogisticRegression only used for scoring. This instance is set `coeffs_` and `intercept_` found before and then calls the desired scoring function. So I have the feeling that it only needs to inheritate from the parameters that impact scoring. 

Scoring indeed could call `predict`,  `predict_proba_lr`, `predict_proba`, `predict_log_proba` and/or `decision_function`, and in these functions the only variable impacted by `LogisticRegression` arguments is `self.multi_class` (in `predict_proba`), as suggested in the discussion .
`self.intercept_` is also sometimes used but it is manually set in these lines 

https://github.com/scikit-learn/scikit-learn/blob/46913adf0757d1a6cae3fff0210a973e9d995bac/sklearn/linear_model/logistic.py#L948-L953

so I think we do not even need to set the `fit_intercept` flag in the empty `LogisticRegression`. Therefore, only `multi_class` argument would need to be set as they are not used. So regarding @aqua4 's comment we wouldn't need to inherit all parameters.

To sum up if this is correct, as suggested by @njiles I would need to inheritate from the `multi_class` argument in the called `LogisticRegression`. And as suggested above I could also delete the settting of `fit_intercept` as the intercept is manually set later in the code so this parameter is useless. 

This would eventually amount to replace this line : 

https://github.com/scikit-learn/scikit-learn/blob/46913adf0757d1a6cae3fff0210a973e9d995bac/sklearn/linear_model/logistic.py#L925

by this one
```python
    log_reg = LogisticRegression(multi_class=multi_class)
```

I am thinking about the testing now but I hope these first element are already correct


Are you continuing with this fix? Test failures need addressing and a non-regression test should be added.
@jnothman Yes, sorry for long idling, I will finish this with tests, soon!