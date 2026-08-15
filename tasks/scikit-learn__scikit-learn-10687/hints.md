So coef_ is a 0-dimensional array. Sounds like a misuse of `np.squeeze`.
Hi, Jnothman, I am new to this community, may I try this one? @jnothman 
Sure, if you understand the problem: add a test, fix it, and open a pull
request.

@jnothman  
This problem happens to Elastic Net too. Not just Lasso. But I did not find it in Ridge. Do you think we should create another issue ticket for the similar problem in Elastic Net?

I will compare the codes between Lasso/ Elastic Net and Ridge and try to get it fixed. I am not quite familiar with the whole process but still learning. So if I got some further questions, may I ask you here ?

Please refer to the codes below for the Elastic Net:
`
import numpy as np
from sklearn import linear_model

est_intercept = linear_model.ElasticNet(fit_intercept=True)
est_intercept.fit(np.c_[np.ones(3)], np.ones(3))
assert est_intercept.coef_.shape  == (1,)


import numpy as np
from sklearn import linear_model

est_no_intercept = linear_model.ElasticNet(fit_intercept=False)
est_no_intercept.fit(np.c_[np.ones(3)], np.ones(3))
assert est_no_intercept.coef_.shape  == (1,)

Traceback (most recent call last):

  File "<ipython-input-12-6eba976ab91b>", line 6, in <module>
    assert est_no_intercept.coef_.shape  == (1,)

AssertionError
`
lasso and elasticnet share an underlying implementation. no need to create
a second issue, but the pr should fix both

On 2 Feb 2018 2:47 pm, "XunOuyang" <notifications@github.com> wrote:

> @jnothman <https://github.com/jnothman>
> This problem happens to Elastic Net too. Not just Lasso. But I did not
> find it in Ridge. Do you think we should create another issue ticket for
> the similar problem in Elastic Net?
>
> I will compare the codes between Lasso/ Elastic Net and Ridge and try to
> get it fixed. I am not quite familiar with the whole process but still
> learning. So if I got some further questions, may I ask you here ?
>
> `
> import numpy as np
> from sklearn import linear_model
>
> est_intercept = linear_model.ElasticNet(fit_intercept=True)
> est_intercept.fit(np.c_[np.ones(3)], np.ones(3))
> assert est_intercept.coef_.shape == (1,)
>
> import numpy as np
> from sklearn import linear_model
>
> est_no_intercept = linear_model.ElasticNet(fit_intercept=False)
> est_no_intercept.fit(np.c_[np.ones(3)], np.ones(3))
> assert est_no_intercept.coef_.shape == (1,)
>
> Traceback (most recent call last):
>
> File "", line 6, in
> assert est_no_intercept.coef_.shape == (1,)
>
> AssertionError
> `
>
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/10571#issuecomment-362478035>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz637mj3jZkxbbyubR_EWxoJQSkm07ks5tQoVEgaJpZM4R1eTP>
> .
>

@jnothman
Hi, I'm a newcomer and I just checked it out.

I used this test:

```python
def test_elastic_net_no_intercept_coef_shape():
    X = [[-1], [0], [1]]
    y = [-1, 0, 1]

    for intercept in [True, False]:
        clf = ElasticNet(fit_intercept=intercept)
        clf.fit(X, y)
        coef_ = clf.coef_
        assert_equal(coef_.shape, (1,))
```

the lines I debugged in ElasticNet.fit() 

``` python
        import pdb; pdb.set_trace()
        self.coef_, self.dual_gap_ = map(np.squeeze, [coef_, dual_gaps_])

        self._set_intercept(X_offset, y_offset, X_scale)

        # workaround since _set_intercept will cast self.coef_ into X.dtype
        self.coef_ = np.asarray(self.coef_, dtype=X.dtype)
        
        # return self for chaining fit and predict calls
        return self
```

and here's the results of debugging: 

```python
test_coordinate_descent.py 
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> PDB set_trace (IO-capturing turned off) >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


******** with intercept

> /scikit-learn/sklearn/linear_model/coordinate_descent.py(763)fit()
-> self.coef_, self.dual_gap_ = map(np.squeeze, [coef_, dual_gaps_])
(Pdb) coef_
array([[ 0.14285714]]) # before np.squeeze

(Pdb) next
> /scikit-learn/sklearn/linear_model/coordinate_descent.py(765)fit()
-> self._set_intercept(X_offset, y_offset, X_scale)
(Pdb) self.coef_
array(0.14285714285714285) # after np.squeeze

(Pdb) next
> /scikit-learn/sklearn/linear_model/coordinate_descent.py(768)fit()
-> self.coef_ = np.asarray(self.coef_, dtype=X.dtype)
(Pdb) self.coef_
array([ 0.14285714]) # after set_intercept

(Pdb) next
> /scikit-learn/sklearn/linear_model/coordinate_descent.py(771)fit()
-> return self
(Pdb) self.coef_
array([ 0.14285714]) # after np.asarray


******** without intercept

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> PDB set_trace (IO-capturing turned off) >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
> /scikit-learn/sklearn/linear_model/coordinate_descent.py(763)fit()
-> self.coef_, self.dual_gap_ = map(np.squeeze, [coef_, dual_gaps_])
(Pdb) coef_
array([[ 0.14285714]]) # before np.squeeze

(Pdb) next
> /scikit-learn/sklearn/linear_model/coordinate_descent.py(765)fit()
-> self._set_intercept(X_offset, y_offset, X_scale)
(Pdb) self.coef_
array(0.14285714285714285) # after np.squeeze

(Pdb) next
> /scikit-learn/sklearn/linear_model/coordinate_descent.py(768)fit()
-> self.coef_ = np.asarray(self.coef_, dtype=X.dtype)
(Pdb) self.coef_
array(0.14285714285714285) # after set_intercept

(Pdb) next
> /scikit-learn/sklearn/linear_model/coordinate_descent.py(771)fit()
-> return self
(Pdb) self.coef_
array(0.14285714285714285) # after np.asarray
```
so if the test case I used is correct it seems like what causes this (or doesn't handle the case) is `base.LinearModel._set_intercept`
```python
    def _set_intercept(self, X_offset, y_offset, X_scale):
        """Set the intercept_
        """
        if self.fit_intercept:
            self.coef_ = self.coef_ / X_scale
            self.intercept_ = y_offset - np.dot(X_offset, self.coef_.T)
        else:
            self.intercept_ = 0.
```
I think it's related to the broadcasting occurring at `self.coef_ = self.coef_ / X_scale ` , which doesn't happen in the second case. 

If that's indeed the case, should it be fixed in this function (which is used by other modules too) or bypass it somehow locally on ElasticNet.fit() ?

@dorcoh, thanks for your analysis. I don't have the attention span now to look through it in detail but perhaps you'd like to review the current patch at #10616 to see if it agrees with your intuitions about what the issue is, and comment there.
you have travis failures.
@agramfort I've made changes, don't know if it is optimal enough. I think you should review it.
Also I have AppVeyor failures on `PYTHON_ARCH=64` which I can not explain.