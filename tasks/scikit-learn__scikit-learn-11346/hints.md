I am taking a look at this

Is it not related to #5481, which seems more generic?

It is, but `SparseEncoder` is not an estimator

> It is, but SparseEncoder is not an estimator

Not that it matters but SparseCoder is an estimator:

``` python
from sklearn.base import BaseEstimator
from sklearn.decomposition import SparseCoder

issubclass(SparseCoder, BaseEstimator)  # True
```

I guess the error wasn't detected in #4807 as it is raised only when using `algorithm='omp'`. It should be raised when testing read only data on `OrthogonalMatchingPursuit` though.

Was there a resolution to this bug? I've run into something similar while doing `n_jobs=-1` on RandomizedLogisticRegression, and didn't know whether I should open a new issue here. Here's the top of my stack:

```
/Users/ali/.pyenv/versions/mvenv/lib/python2.7/site-packages/sklearn/linear_model/randomized_l1.py in _randomized_logistic(X=memmap([[ -4.24636666e-03,  -5.10115749e-03,  -1...920913e-03,  -1.46599832e-03,   2.91083847e-03]]), y=array([1, 0, 0, ..., 0, 0, 0]), weights=array([ 0. ,  0.5,  0.5,  0. ,  0. ,  0. ,  0.5,... 0.5,  0.5,  0. ,  0. ,  0.5,  0. ,
        0.5]), mask=array([ True,  True, False, ...,  True,  True,  True], dtype=bool), C=1.5, verbose=0, fit_intercept=True, tol=0.001)
    351     if issparse(X):
    352         size = len(weights)
    353         weight_dia = sparse.dia_matrix((1 - weights, 0), (size, size))
    354         X = X * weight_dia
    355     else:
--> 356         X *= (1 - weights)
        X = memmap([[ -4.24636666e-03,  -5.10115749e-03,  -1...920913e-03,  -1.46599832e-03,   2.91083847e-03]])
        weights = array([ 0. ,  0.5,  0.5,  0. ,  0. ,  0. ,  0.5,... 0.5,  0.5,  0. ,  0. ,  0.5,  0. ,
        0.5])
    357 
    358     C = np.atleast_1d(np.asarray(C, dtype=np.float))
    359     scores = np.zeros((X.shape[1], len(C)), dtype=np.bool)
    360 

ValueError: output array is read-only
```

Someone ran into the [same exact problem](http://stackoverflow.com/questions/27740804/scikit-learn-randomized-logistic-regression-gives-valueerror-output-array-is-r) on StackOverflow - `ValueError: output array is read-only`. Both provided solutions on SO are useless (the first one doesn't even bother solving the problem, and the second one is solving the problem by bypassing joblib completely).

@alichaudry I just commented on a similar issue [here](https://github.com/scikit-learn/scikit-learn/issues/6614#issuecomment-208815649).

I confirm that there is an error and it is floating in nature.

sklearn.decomposition.SparseCoder(D, transform_algorithm = 'omp', n_jobs=64).transform(X) 

if X.shape[0] > 4000 it fails with ValueError: assignment destination is read-only
If X.shape[0] <100 it is ok.

OS: Linux  3.10.0-327.13.1.el7.x86_64
 python: Python 2.7.5
 numpy: 1.10.1
 sklearn: 0.17

Hi there,
I'm running into the same problem, using MiniBatchDictionaryLearning with jobs>1.
I see a lot of referencing to other issues, but was there ever a solution to this? 
Sorry in advance if a solution was mentioned and I missed it.

OS: OSX
python: 3.5
numpy: 1.10.1
sklearn: 0.17

The problem is in modifying arrays in-place. @lesteve close as duplicate of #5481?

currently I am still dealing with this issue and it is nearly a year since. this is still an open issue. 
If you have a solution, please contribute it, @williamdjones 
https://github.com/scikit-learn/scikit-learn/pull/4807 is probably the more advanced effort to address this.
@williamdjones I was not suggesting that it's solved, but that it's an issue that is reported at a different place, and having multiple issues related to the same problem makes keeping track of it harder.
Not sure where to report this, or if it's related, but I get the `ValueError: output array is read-only` when using n_jobs > 1 with RandomizedLasso and other functions.
@JGH1000 NOT A SOLUTION, but I would try using a random forest for feature selection instead since it is stable and has working joblib functionality.
Thanks @williamdjones, I used several different methods but found that RandomizedLasso works best for couple of particular datasets. In any case, it works but a bit slow. Not a deal breaker.
@JGH1000 No problem. If you don't mind, I'm curious about the dimensionality of the datasets for which RLasso was useful versus those for which it was not. 
@williamdjones it was a small sample size (40-50), high-dimension (40,000-50,000) dataset. I would not say that other methods were bad, but RLasso provided results/ranking that were much more consistent with several univariate tests + domain knowledge. I guess this might not be the 'right' features but I had more trust in this method. Shame to hear it will be removed from scikit. 
The problem still seems to exist on 24 core Ubuntu processor for RLasso with n_jobs = -1 and sklearn 0.19.1