I think that this is on purpose. Otherwise, we would have used `closed="neither"` for the `Real` case and `1` is qualified as a `Real`.

At least this is not a regression since the code in the past would have failed and now we allow it to be considered as 100% of the train set.

If we exclude `1` it means that we don't accept both 100% and 1. I don't know if this is something that we want.
Note that with sklearn 1.0, `min_samples_split=1.0` does not raise an exception, only `min_samples_split=1`.
Reading the docstring, I agree it is strange to interpret the integer `1` as 100%:

https://github.com/scikit-learn/scikit-learn/blob/baefe83933df9abecc2c16769d42e52b2694a9c8/sklearn/tree/_classes.py#L635-L638

From the docstring, `min_samples_split=1` is interpreted as 1 sample, which does not make any sense. 

I think we should be able to specify "1.0" but not "1" in our parameter validation framework. @jeremiedbb What do you think of having a way to reject `Integral`, such as:

```python
Interval(Real, 0.0, 1.0, closed="right", invalid_type=Integral),
```

If we have a way to specify a `invalid_type`, then I prefer to reject `min_samples_split=1` as we did in previous versions. 
Also note that `min_samples_split=1.0` and `min_samples_split=1` do not result in the same behavior:

https://github.com/scikit-learn/scikit-learn/blob/baefe83933df9abecc2c16769d42e52b2694a9c8/sklearn/tree/_classes.py#L257-L263

If `min_samples_split=1`, the actual `min_samples_split` is determine by `min_samples_leaf`:
```python
min_samples_split = max(min_samples_split, 2 * min_samples_leaf)
```

If `min_samples_split=1.0` and assuming there are more than 2 samples in the data, `min_samples_split = n_samples`:
```python
min_samples_split = int(ceil(self.min_samples_split * n_samples))
```