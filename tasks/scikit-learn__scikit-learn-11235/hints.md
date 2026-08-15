See also #11181  where @amueller suggests deprecating with_mean

I haven't understood the inconsistency here though. Please give an expected/actual
> See also #11181 where @amueller suggests deprecating with_mean.

So 2. will be better then.

> I haven't understood the inconsistency here though. Please give an expected/actual

Let's suppose the following

```python
from scipy import sparse                                                   
from sklearn.preprocessing import StandardScaler                                                                                                        
X_sparse = sparse.random(1000, 10).tocsr()                                                              
X_dense = X_sparse.A
transformer = StandardScaler(with_mean=False, with_std=False)   
```

### sparse case

```python
transformer.fit(X_sparse)
StandardScaler(copy=True, with_mean=False, with_std=False)
print(transformer.mean_)
None
```

### dense case

```python
transformer.fit(X_dense)
StandardScaler(copy=True, with_mean=False, with_std=False)
print(transformer.mean_)
[0.00178285 0.00319143 0.00503664 0.00550827 0.00728271 0.00623176
 0.00537122 0.00937145 0.00786976 0.00254072]
```

### issue with `n_samples_seen_` not created at fit with sparse.

```python
transformer.fit(X_sparse)
StandardScaler(copy=True, with_mean=False, with_std=False)
transformer.fit(X_sparse)
```
```
---------------------------------------------------------------------------
AttributeError                            Traceback (most recent call last)
<ipython-input-19-66c50efa396c> in <module>()
----> 1 transformer.fit(X_sparse)

~/Documents/code/toolbox/scikit-learn/sklearn/preprocessing/data.py in fit(self, X, y)
    610 
    611         # Reset internal state before fitting
--> 612         self._reset()
    613         return self.partial_fit(X, y)
    614 

~/Documents/code/toolbox/scikit-learn/sklearn/preprocessing/data.py in _reset(self)
    585         if hasattr(self, 'scale_'):
    586             del self.scale_
--> 587             del self.n_samples_seen_
    588             del self.mean_
    589             del self.var_

AttributeError: n_samples_seen_
```