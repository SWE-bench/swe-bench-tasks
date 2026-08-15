We have 2 solutions:

* make `ArrayDataset**` more permissive to accept C and F arrays and internally call `check_array` in `__cninit__`
* make a `check_array` in the `make_dataset` function

What's best?
> make ArrayDataset** more permissive to accept C and F arrays and internally call check_array in __cninit__

I guess the problem here is not that it's F ordered, but that it's non contiguous.

+1 to add `check_array` in the make_dataset function
Actually, `X[:, [1,3,4]]` is F contiguous
But `X[:, ::2]` isn't so I'm also +1 for check_array
Also it looks like `Ridge(solver="sag")` is not run in common tests, as otherwise it would fail with another reason,
<details>

```
In [2]: from sklearn.linear_model import Ridge                                                                                                 
In [4]: from sklearn.utils.estimator_checks import check_estimator                                 
In [5]: check_estimator(Ridge(solver='sag'))                                                                                                   
/home/rth/src/scikit-learn/sklearn/linear_model/ridge.py:558: UserWarning: "sag" solver requires many iterations to fit an intercept with sparse inputs. Either set the solver to "auto" or "sparse_cg", or set a low "tol" and a high "max_iter" (especially if inputs are not standardized).
  '"sag" solver requires many iterations to fit '
/home/rth/src/scikit-learn/sklearn/linear_model/ridge.py:558: UserWarning: "sag" solver requires many iterations to fit an intercept with sparse inputs. Either set the solver to "auto" or "sparse_cg", or set a low "tol" and a high "max_iter" (especially if inputs are not standardized).
  '"sag" solver requires many iterations to fit '
/home/rth/src/scikit-learn/sklearn/linear_model/ridge.py:558: UserWarning: "sag" solver requires many iterations to fit an intercept with sparse inputs. Either set the solver to "auto" or "sparse_cg", or set a low "tol" and a high "max_iter" (especially if inputs are not standardized).
  '"sag" solver requires many iterations to fit '
/home/rth/src/scikit-learn/sklearn/linear_model/ridge.py:558: UserWarning: "sag" solver requires many iterations to fit an intercept with sparse inputs. Either set the solver to "auto" or "sparse_cg", or set a low "tol" and a high "max_iter" (especially if inputs are not standardized).
  '"sag" solver requires many iterations to fit '
/home/rth/src/scikit-learn/sklearn/linear_model/ridge.py:558: UserWarning: "sag" solver requires many iterations to fit an intercept with sparse inputs. Either set the solver to "auto" or "sparse_cg", or set a low "tol" and a high "max_iter" (especially if inputs are not standardized).
  '"sag" solver requires many iterations to fit '
/home/rth/src/scikit-learn/sklearn/linear_model/ridge.py:558: UserWarning: "sag" solver requires many iterations to fit an intercept with sparse inputs. Either set the solver to "auto" or "sparse_cg", or set a low "tol" and a high "max_iter" (especially if inputs are not standardized).
  '"sag" solver requires many iterations to fit '
/home/rth/src/scikit-learn/sklearn/linear_model/ridge.py:558: UserWarning: "sag" solver requires many iterations to fit an intercept with sparse inputs. Either set the solver to "auto" or "sparse_cg", or set a low "tol" and a high "max_iter" (especially if inputs are not standardized).
  '"sag" solver requires many iterations to fit '
/home/rth/src/scikit-learn/sklearn/linear_model/ridge.py:558: UserWarning: "sag" solver requires many iterations to fit an intercept with sparse inputs. Either set the solver to "auto" or "sparse_cg", or set a low "tol" and a high "max_iter" (especially if inputs are not standardized).
  '"sag" solver requires many iterations to fit '
/home/rth/src/scikit-learn/sklearn/linear_model/ridge.py:558: UserWarning: "sag" solver requires many iterations to fit an intercept with sparse inputs. Either set the solver to "auto" or "sparse_cg", or set a low "tol" and a high "max_iter" (especially if inputs are not standardized).
  '"sag" solver requires many iterations to fit '
/home/rth/src/scikit-learn/sklearn/linear_model/ridge.py:558: UserWarning: "sag" solver requires many iterations to fit an intercept with sparse inputs. Either set the solver to "auto" or "sparse_cg", or set a low "tol" and a high "max_iter" (especially if inputs are not standardized).
  '"sag" solver requires many iterations to fit '
---------------------------------------------------------------------------
ZeroDivisionError                         Traceback (most recent call last)
<ipython-input-5-79acf8fdbc1d> in <module>
----> 1 check_estimator(Ridge(solver='sag'))

~/src/scikit-learn/sklearn/utils/estimator_checks.py in check_estimator(Estimator)
    298     for check in _yield_all_checks(name, estimator):
    299         try:
--> 300             check(name, estimator)
    301         except SkipTest as exception:
    302             # the only SkipTest thrown currently results from not

~/src/scikit-learn/sklearn/utils/testing.py in wrapper(*args, **kwargs)
    324             with warnings.catch_warnings():
    325                 warnings.simplefilter("ignore", self.category)
--> 326                 return fn(*args, **kwargs)
    327 
    328         return wrapper

~/src/scikit-learn/sklearn/utils/estimator_checks.py in check_fit2d_1sample(name, estimator_orig)
    895 
    896     try:
--> 897         estimator.fit(X, y)
    898     except ValueError as e:
    899         if all(msg not in repr(e) for msg in msgs):

~/src/scikit-learn/sklearn/linear_model/ridge.py in fit(self, X, y, sample_weight)
    762         self : returns an instance of self.
    763         """
--> 764         return super().fit(X, y, sample_weight=sample_weight)
    765 
    766 

~/src/scikit-learn/sklearn/linear_model/ridge.py in fit(self, X, y, sample_weight)
    597                 max_iter=self.max_iter, tol=self.tol, solver=solver,
    598                 random_state=self.random_state, return_n_iter=True,
--> 599                 return_intercept=False, check_input=False, **params)
    600             self._set_intercept(X_offset, y_offset, X_scale)
    601 

~/src/scikit-learn/sklearn/linear_model/ridge.py in _ridge_regression(X, y, alpha, sample_weight, solver, max_iter, tol, verbose, random_state, return_n_iter, return_intercept, X_scale, X_offset, check_input)
    490                 max_iter, tol, verbose, random_state, False, max_squared_sum,
    491                 init,
--> 492                 is_saga=solver == 'saga')
    493             if return_intercept:
    494                 coef[i] = coef_[:-1]

~/src/scikit-learn/sklearn/linear_model/sag.py in sag_solver(X, y, sample_weight, loss, alpha, beta, max_iter, tol, verbose, random_state, check_input, max_squared_sum, warm_start_mem, is_saga)
    305                                    is_saga=is_saga)
    306     if step_size * alpha_scaled == 1:
--> 307         raise ZeroDivisionError("Current sag implementation does not handle "
    308                                 "the case step_size * alpha_scaled == 1")
    309 

ZeroDivisionError: Current sag implementation does not handle the case step_size * alpha_scaled == 1
```

</details>

> Actually, X[:, [1,3,4]] is F contiguous

Wow, yes, I wasn't aware of that.
