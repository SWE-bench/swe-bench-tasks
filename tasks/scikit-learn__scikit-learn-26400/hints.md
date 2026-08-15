Thank you for opening the issue. I agree this is a bug. It is reasonable to return all nans to be consistent with `yeo-johnson`.
Would the following approach be neat enough?

```python
def _box_cox_optimize(self, x):
    # The computation of lambda is influenced by NaNs so we need to
    # get rid of them
    x = x[~np.isnan(x)]
        
    # if the whole column is nan, we do not care about lambda
    if len(x) == 0:
        return 0
        
    _, lmbda = stats.boxcox(x, lmbda=None)
    return lmbda

```
If this is okay, I can open a PR for this.
On second thought, `box-cox` does not work when the data is constant:

```python
from sklearn.preprocessing import PowerTransformer

x = [[1], [1], [1], [1]]

pt = PowerTransformer(method="box-cox")
pt.fit_transform(x)
# ValueError: Data must not be constant.
```

A feature that is all `np.nan` can be considered constant. If we want to stay consistent, then we raise a similar error for all `np.nan`.

With that in mind, I'm in favor of raising an informative error.
@thomasjpfan That's indeed reasonable. I have two proposed solutions:

1. Let scipy raise the error, so that the message will be consistent with scipy:

```python
def _box_cox_optimize(self, x):
    if not np.all(np.isnan(x)):
        x = x[~np.isnan(x)]

    _, lmbda = stats.boxcox(x, lmbda=None)
    return lmbda
```

2. Raise our own error, specifically claiming that column cannot be all nan (rather than cannot be constant):

```python
def _box_cox_optimize(self, x):
    if np.all(np.isnan(x)):
        raise ValueError("Column must not be all nan.")

    _, lmbda = stats.boxcox(x[~np.isnan(x)], lmbda=None)
    return lmbda
```

Which one would you prefer, our do you have any other recommended solution? (I'm thinking that maybe my proposed solutions are not efficient enough.)
Since there is no reply, I'm going to open a PR that takes the second approach. The reason is that the second approach is clearer IMO and the first approach seems to trigger some unexpected behavior.
I like the second approach in https://github.com/scikit-learn/scikit-learn/issues/26303#issuecomment-1536899848, but store the `np.isnan(x)` as a variable so it is not computed twice.
I see, thanks for the comment!