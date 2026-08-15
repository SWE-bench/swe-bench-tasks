@mayer79, have you already started working on this issue? I would love to solve it if you didn't. :)
@vitaliset Not yet started! I would be super happy if you could dig into this. 

I think there are two ways to calculate PDPs. For the model agnostic logic, we would probably need to replace `np.mean()` by `np.average()`. There is a second (fast exact) way for trees based on Friedman's algorithm. Here, I am not sure if the change is straightforward, but in the worst case we would just say "The fast exact PDP for trees does not support case weights".
Thanks for giving me the direction I should follow, @mayer79! ;) I took a look at it during the last few days, and here is what I found:

___

## `method='brute'`

`np.average` does look like the right call here. From a quick and dirty change on the source code, it seems to be doing the trick!

For designing tests, I came up with something like:
- Using `load_iris` and a few models, assert that the average for `sample_weight=[1, 0, ..., 0]` is equal to the ICE for the first example;
- Using `load_iris` and a few models, assert that the average for `sample_weight=[1, 1, 0, ..., 0]` is equal to the average with `sample_weight=None` for the first two examples...

Do you see any other tests that I should add?

___

## `method='recursion'`

For the `method='recursion'` (fast PDP for trees), the algorithm is harder to understand, but I found [this blog post](https://nicolas-hug.com/blog/pdps) from @NicolasHug that made going through the source code a lot easier to digest (thanks Nicolas!).

From what I understand from the code, **it does not look at the given `X`** for this method. It only uses `X` to create the grid values it will explore.

https://github.com/scikit-learn/scikit-learn/blob/c1cfc4d4f36f9c00413e20d0ef85bed208a502ca/sklearn/inspection/_partial_dependence.py#L523-L528

Note that `grid` is just the grid of values we will iterate over for the PDP calculations: 
```python
import numpy as np
from sklearn import __version__ as v
print("numpy:", np.__version__, ". sklearn:", v)
>>> numpy: 1.23.3 . sklearn: 1.1.3

from sklearn.inspection._partial_dependence import _grid_from_X
from sklearn.utils import _safe_indexing
from sklearn.datasets import load_diabetes
X, _ = load_diabetes(return_X_y=True)

grid, values = \
_grid_from_X(X=_safe_indexing(X, [2, 8], axis=1), percentiles=(0,1), grid_resolution=100)

print("original shape of X:", X.shape, "shape of grid:", grid.shape)
>>> original shape of X:  (442, 10) shape of grid:  (10000, 2)

print(len(values), values[0].shape)
>>> 2 (100,)

from itertools import product
print((grid == np.array(list(product(values[0], values[1])))).all())
>>> True
```

The `grid` variable is not `X` with repeated rows (for each value of the grid) like we would expect for `method='brute'`. Inside the `_partial_dependence_brute` function we actually do this later:

https://github.com/scikit-learn/scikit-learn/blob/c1cfc4d4f36f9c00413e20d0ef85bed208a502ca/sklearn/inspection/_partial_dependence.py#L160-L163

This `grid` variable is what is being passed on the PDP calculations, not `X`:

https://github.com/scikit-learn/scikit-learn/blob/c1cfc4d4f36f9c00413e20d0ef85bed208a502ca/sklearn/inspection/_partial_dependence.py#L119-L120

When looking for the average for a specific value in the grid, it does one run on the tree and checks the proportion of samples (from the **training data**) that pass through each leaf when we have a split (when the feature of the split is not the feature we are making the dependence plot of).

https://github.com/scikit-learn/scikit-learn/blob/9268eea91f143f4f5619f7671fdabf3ecb9adf1a/sklearn/tree/_tree.pyx#L1225-L1227

Note that `weighted_n_node_samples` is an attribute from the tree.

___

## `method='recursion'` uses the `sample_weight` from training data... but not always

Nonetheless, I found something "odd". There are two slightly different implementations of the `compute_partial_dependence` function on scikit-learn—one for the models based on the CART implementation and one for the estimators of the HistGradientBoosting. The algorithms based on the CART implementation use the `sample_weight` of the `.fit` method through the `weighted_n_node_samples` attribute (code above).

While the estimators of HistGradientBoosting doesn't. It just counts the number of samples on the leaf (even if it was fitted with `sample_weight`).

https://github.com/scikit-learn/scikit-learn/blob/ff6f880755d12a380dbdac99f6b9d169aee8b588/sklearn/ensemble/_hist_gradient_boosting/_predictor.pyx#L190-L192

You can see that looks right from this small code I ran:
```python
import numpy as np
from sklearn import __version__ as v
print("numpy:", np.__version__, ". sklearn:", v)
>>> numpy: 1.23.3 . sklearn: 1.1.3

from sklearn.datasets import load_diabetes
X, y = load_diabetes(return_X_y=True)
sample_weights = np.random.RandomState(42).uniform(0, 1, size=X.shape[0])

from sklearn.tree import DecisionTreeRegressor
dtr_nsw = DecisionTreeRegressor(max_depth=1, random_state=42).fit(X, y)
dtr_sw  = DecisionTreeRegressor(max_depth=1, random_state=42).fit(X, y, sample_weight=sample_weights)

print(dtr_nsw.tree_.weighted_n_node_samples, dtr_sw.tree_.weighted_n_node_samples)
>>> [442. 218. 224.] [218.28015122 108.90401865 109.37613257]

from sklearn.ensemble import RandomForestRegressor
rfr_nsw = RandomForestRegressor(max_depth=1, random_state=42).fit(X, y)
rfr_sw  = RandomForestRegressor(max_depth=1, random_state=42).fit(X, y, sample_weight=sample_weights)

print(rfr_nsw.estimators_[0].tree_.weighted_n_node_samples, rfr_sw.estimators_[0].tree_.weighted_n_node_samples)
>>> [442. 288. 154.] [226.79228463 148.44294465  78.34933998]

from sklearn.ensemble import HistGradientBoostingRegressor
hgbr_nsw = HistGradientBoostingRegressor(max_depth=2, random_state=42).fit(X, y)
hgbr_sw  = HistGradientBoostingRegressor(max_depth=2, random_state=42).fit(X, y, sample_weight=sample_weights)

import pandas as pd
pd.DataFrame(hgbr_nsw._predictors[0][0].nodes)
```
![Imagem 14-12-2022 às 18 23](https://user-images.githubusercontent.com/55899543/207718358-0de78ffa-ded0-4f45-9e9d-142a03905e2a.jpeg)
```
pd.DataFrame(hgbr_sw._predictors[0][0].nodes)
```
![Imagem 14-12-2022 às 18 28](https://user-images.githubusercontent.com/55899543/207718727-5304ece8-bf39-418d-804a-70fd95ea5d25.jpeg)

The `weighted_n_node_samples` attribute takes weighting in count (as it is a `float`) while the `.count` from predictors looks only at the number of samples at each node (as it is an `int`).

___

## Takeaways

- The `method='brute'` should be straightforward, and I'll create a PR for it soon. I'm still determining the tests, but I can add extra ones during review time.
- Because it explicitly doesn't use the `X` for the PDP calculations when we have `method='recursion'`, I don't think it makes sense to try to implement `sample_weight` on it, and I'll create an error for it.
- Nonetheless, we can discuss the mismatch between calculating the PDP with training `sample_weight` or not that we see using different models and make it uniform across algorithms if we think this is relevant. It doesn't look like a big priority, but knowing we have this problem is nice. I don't think it should be that hard to keep track of the weighted samples on the `nodes` attribute.
Fantastic research! 

Additional possible tests for "brute": PDP unweighted is the same as PDP with all weights 1.0. Same for all weights 2.0.

My feeling is : the "recurse" approach for trees should respect sample weights of the training data when tracking split weights. I cannot explain why the two tree-methods are different. Should we open an issue for clarification? 
> The algorithms based on the CART implementation use the sample_weight of the .fit method through the weighted_n_node_samples attribute (code above).
> While the estimators of HistGradientBoosting doesn't.

That's correct - this is something that is explicitly not supported in the HGBDT trees yet:

https://github.com/scikit-learn/scikit-learn/blob/205f3b76ef8500c90c346c6c6fb6f4e589368278/sklearn/ensemble/_hist_gradient_boosting/gradient_boosting.py#L1142-L1148

(See https://github.com/scikit-learn/scikit-learn/pull/14696#issuecomment-548295813 for historical decision / context)

I thought there was an open issue for that, but it looks like there isn't. Feel free to open one! 