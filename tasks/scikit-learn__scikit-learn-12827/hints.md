Sounds like a good improvement. Could you maybe submit a PR with the improvements you have in mind? I guess it should go in the relevant [user guide](https://scikit-learn.org/dev/modules/preprocessing.html#preprocessing-transformer).
I will open a PR with the improvements of the doc. 

> Besides I was thinking that to map to a uniform distribution, the implementation was just computing the empirical cdf of the columns but it does not seem to be the case.

I investigated the code a bit more. I think that when `output_distribution='uniform'` the statement [L2250](https://github.com/scikit-learn/scikit-learn/blob/cd8fe16/sklearn/preprocessing/data.py#L2250)

```python
X_col = output_distribution.ppf(X_col)
```

is not needed as for a uniform distribution on (0, 1) the quantile function `ppf` is the identity function. In this case the implementation would just compute the empirical cdf which would correspond to what I think it should be doing. Unless there was a reason to use `ppf` even for the uniform output? cc @glemaitre @ogrisel

PS: I also had a look at the `QuantileTransformer` PR, this is impressive work!

