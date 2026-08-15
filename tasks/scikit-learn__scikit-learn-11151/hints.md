Do you mean deprecation warnings like the one below? If you can guide me a little, I am happy to work on this issue. 
![image](https://user-images.githubusercontent.com/5948157/40274153-453622a6-5c02-11e8-8e50-29d341612e02.png)

I meant deprecation warnings raised in scikit-learn, not in Numpy. That one you mention is during compilation. I meant during testing.
On your machine, you can run the tests with `pytest -r a sklearn`. At the end of the script, pytest prints a "warnings summary". It would be great to silence the expected warnings, such as convergence warnings.

Example: `pytest -r a sklearn/linear_model/tests/test_coordinate_descent.py`:
```
sklearn/linear_model/tests/test_coordinate_descent.py ...................................

=========================================================== warnings summary ============================================================
sklearn/linear_model/tests/test_coordinate_descent.py::test_lasso_cv_with_some_model_selection
  /cal/homes/tdupre/work/src/scikit-learn/sklearn/model_selection/_split.py:605: Warning: The least populated class in y has only 1 members, which is too few. The minimum number of members in any class cannot be less than n_splits=5.
    % (min_groups, self.n_splits)), Warning)

sklearn/linear_model/tests/test_coordinate_descent.py::test_multitask_enet_and_lasso_cv
  /cal/homes/tdupre/work/src/scikit-learn/sklearn/linear_model/coordinate_descent.py:1783: ConvergenceWarning: Objective did not converge, you might want to increase the number of iterations
    ConvergenceWarning)
  /cal/homes/tdupre/work/src/scikit-learn/sklearn/linear_model/coordinate_descent.py:1783: ConvergenceWarning: Objective did not converge, you might want to increase the number of iterations
    ConvergenceWarning)

sklearn/linear_model/tests/test_coordinate_descent.py::test_check_input_false
  /cal/homes/tdupre/work/src/scikit-learn/sklearn/linear_model/coordinate_descent.py:491: ConvergenceWarning: Objective did not converge. You might want to increase the number of iterations. Fitting data with very small alpha may cause precision problems.
    ConvergenceWarning)
```

To silence warnings, see `sklearn.utils.testing.ignore_warnings`:
https://github.com/scikit-learn/scikit-learn/blob/4b24fbedf5fa3b7b6b559141ad78708145b09704/sklearn/utils/testing.py#L269-L292
Hi, I am looking into this issue, I figure the "common tests" means the test_common.py under the tests directory? I tried running the test but no warning is generated, could you tell me what warning is expected? Thanks a lot.
```
============================================= test session starts =============================================
platform darwin -- Python 3.6.1, pytest-3.0.7, py-1.4.33, pluggy-0.4.0
rootdir: /Users/sw/programming/opensourceproject/scikit-learn, inifile: setup.cfg
plugins: pep8-1.0.6
collected 4822 items

test_common.py .........................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................s............................................................................s............................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................s.........................................................................................................................................................................................................................................................................................................s................................................................................................................................................................................................................................s..................................s..............................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................s............................................................................................................................................................................................................................................................................s........................................................................................................................................................................................................................................................................................................................................................................................................................
=========================================== short test summary info ===========================================
SKIP [1] /anaconda/lib/python3.6/site-packages/_pytest/nose.py:23: score_samples of BernoulliRBM is not invariant when applied to a subset.
SKIP [3] /anaconda/lib/python3.6/site-packages/_pytest/nose.py:23: Skipping check_estimators_data_not_an_array for cross decomposition module as estimators are not deterministic.
SKIP [1] /anaconda/lib/python3.6/site-packages/_pytest/nose.py:23: transform of MiniBatchSparsePCA is not invariant when applied to a subset.
SKIP [1] /anaconda/lib/python3.6/site-packages/_pytest/nose.py:23: Not testing NuSVC class weight as it is ignored.
SKIP [1] /anaconda/lib/python3.6/site-packages/_pytest/nose.py:23: decision_function of SVC is not invariant when applied to a subset.
SKIP [1] /anaconda/lib/python3.6/site-packages/_pytest/nose.py:23: transform of SparsePCA is not invariant when applied to a subset.

=================================== 4814 passed, 8 skipped in 72.05 seconds ===================================
```

>  figure the "common tests" means the test_common.py under the tests directory? 

Yes

> I tried running the test but no warning is generated

You need to add the `-r a` pytest CLI option as indicated in https://github.com/scikit-learn/scikit-learn/issues/11109#issuecomment-391061304
Huh, That's weird. I did have `-r a`, and the command was: `pytest -r a sklearn/tests/test_common.py`. But as shown above, no warning was generated, I tried `pytest -r a sklearn/tests/test_common.py --strict` and found one deprecationwarning and a bunch of errors.
figured out, I was using an older pytest verision.
Last time I looked at this, I realised that one of the problem (there may be more) was that `assert_warns_*` resets `warnings.filters` which overrides the `ignore_warnings` used as a decorator. It does not seem like a great idea and the reason for it is slightly unclear. Below is a snippet to show the problem:

```py
import warnings

import pytest

from sklearn.utils.testing import ignore_warnings
from sklearn.utils.testing import assert_warns_message


def warns():
    warnings.warn("some warning")
    return 1


@ignore_warnings()
def test_1():
    print('before:', warnings.filters)
    assert_warns_message(UserWarning, 'some warning', warns)
    print('after:', warnings.filters)
    # This warning is visible because assert_warns_message resets
    # warnings.filters.
    warns()


def test_12():
    print('test12:', warnings.filters)


ignore_common_warnings = pytest.mark.filterwarnings('ignore::UserWarning')


@ignore_common_warnings
def test_2():
    warns()


@ignore_common_warnings
def test_3():
    assert_warns_message(UserWarning, 'some warning', warns)
    # This warning is visible
    warns()

```

```
❯ pytest /tmp/test-warnings.py -s 
======================================================== test session starts ========================================================
platform linux -- Python 3.6.5, pytest-3.5.1, py-1.5.3, pluggy-0.6.0
rootdir: /tmp, inifile:
plugins: timeout-1.2.1, flake8-0.9.1, cov-2.5.1, hypothesis-3.56.0
collected 3 items                                                                                                                   

../../../../../tmp/test-warnings.py before: [('ignore', None, <class 'Warning'>, None, 0)]
after: []
...

========================================================= warnings summary ==========================================================
test-warnings.py::test_1
  /tmp/test-warnings.py:10: UserWarning: some warning
    warnings.warn("some warning")

test-warnings.py::test_3
  /tmp/test-warnings.py:10: UserWarning: some warning
    warnings.warn("some warning")

-- Docs: http://doc.pytest.org/en/latest/warnings.html
=============================================== 3 passed, 2 warnings in 0.18 seconds ================================================
```
Interesting. I would be in favor of replacing `assert_warns_message(UserWarning, 'some warning', warn)` with,
```py
with pytest.warns(UserWarning, match='some warning'):
   warn()
```
to avoid dealing with it..
If someone has a semi-automated way of replacing the `assert_warns*`, why not, but it could well be the case that some downstream packages are using them.

Maybe implementing `assert_warns_*` in terms of `pytest_warns` is a less tedious and less intrusive change to implement, i.e. something like this (not tested):

```py
def assert_warns_regex(warning_cls, warning_message, func, *args, **kwargs):
    with pytest.warns(warning_cls, match=re.escape(warning_message)):
        func(*args, **kwargs)
```    

The reason is that there were bugs in Python around warning registry.
pytest might have ironed out the wrinkles, so I'm +1 for using or wrapping
it if possible.

> but it could well be the case that some downstream packages are using them.

We could still keep `assert_warns_*` for a deprecation cycle in `utils/testing.py` in any case

> Maybe implementing assert_warns_* in terms of pytest_warns is a less tedious and less intrusive change to implement

True, that would be faster, but then there isn't that many lines to change,
```sh
% git grep assert_warns_message | wc -l                 [master] 
162
% git grep assert_warns | wc -l                         [master] 
319
```
to warant keeping a wrapper, I think. Directly using pytest warning capture in the code base without a wrapper would be IMO cleaner for contributors reading the code... That could be a part of cleaning up `assert_*` functions in general https://github.com/scikit-learn/scikit-learn/issues/10728#issuecomment-369229766 
That makes sense, thanks a lot. But when I tried replacing the `assert_warns_*` (including `assert_warns`) with `pytest_warns` as @lesteve suggested, I still got all those warnings. 

And there is sth that wasn't clear to me: when using `ignore_warnings` as decorator, the code is 
```
    def __call__(self, fn):
        """Decorator to catch and hide warnings without visual nesting."""
        @wraps(fn)
        def wrapper(*args, **kwargs):
            # very important to avoid uncontrolled state propagation
            clean_warning_registry()
            with warnings.catch_warnings():
                warnings.simplefilter("ignore", self.category)
                return fn(*args, **kwargs)

        return wrapper
```
Isn't the `clean_warning_registry()` also reset the filters?
`clean_warning_registry` is what resets `warnings.filters` indeed, so `ignore_warnings` has the same problem (there may be others).

Not sure what you have tried but if I were you I would try to look at a single test that shows a problem, for example, I get a ConvergenceWarning with this test:
```
❯ pytest sklearn/tests/test_common.py -r a -k 'test_non_meta_estimators and TheilSen and subset_invariance'
======================================================== test session starts ========================================================
platform linux -- Python 3.6.5, pytest-3.5.1, py-1.5.3, pluggy-0.6.0
rootdir: /home/local/lesteve/dev/scikit-learn, inifile: setup.cfg
plugins: timeout-1.2.1, flake8-0.9.1, cov-2.5.1, hypothesis-3.56.0
collected 4822 items / 4821 deselected                                                                                              

sklearn/tests/test_common.py .                                                                                                [100%]

========================================================= warnings summary ==========================================================
sklearn/tests/test_common.py::test_non_meta_estimators[TheilSenRegressor-TheilSenRegressor-check_methods_subset_invariance]
  /home/local/lesteve/dev/scikit-learn/sklearn/linear_model/theil_sen.py:128: ConvergenceWarning: Maximum number of iterations 5 reached in spatial median for TheilSen regressor.
    "".format(max_iter=max_iter), ConvergenceWarning)

-- Docs: http://doc.pytest.org/en/latest/warnings.html
======================================= 1 passed, 4821 deselected, 1 warnings in 1.30 seconds =======================================
```

print `warnings.filters` (use `-s` to show stdout in pytest) and try to figure out why `warnings.simplefilter("ignore", ConvergenceWarning)` [here](https://github.com/scikit-learn/scikit-learn/blob/20cb37e8f6e1eb6859239bac6307fcc213ddd52e/sklearn/utils/estimator_checks.py#L330) does not seem to have any effect.
Can I just comment out the `clean_warning_registry()` in `ignore_warnings` then? That seems to solve all the problems. 
We may not have strong enough tests to check it, but I promise
clean_warnings_registry is there for a reason!

Oh, but what I hadn't realised is that:

 when using ignore_warnings as a wrapper, it uses a catch_warnings context
manager.

when using ignore_warnings as a context manager, it does not use a
catch_warnings context manager. I think this is a bug. Could using a
catch_warnings context in ignore_warnings.__enter__ help solve the issue
here?
​
