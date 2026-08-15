I can reproduce it. We need to investigate but I would expect the inner estimator not being able to handle some dataframe because we expected NumPy arrays before.
This could be a bit like https://github.com/scikit-learn/scikit-learn/pull/25370 where things get confused when pandas output is configured. I think the solution is different (TSNE's PCA is truely "internal only") but it seems like there might be something more general to investigate/think about related to pandas output and nested estimators.
There is something quite smelly regarding the interaction between `IsotonicRegression` and pandas output:

<img width="1079" alt="image" src="https://user-images.githubusercontent.com/7454015/215147695-8aa08b83-705b-47a4-ab7c-43acb222098f.png">

It seems that we output a pandas Series when calling `predict` which is something that we don't do for any other estimator. `IsotonicRegression` is already quite special since it accepts a single feature. I need to investigate more to understand why we wrap the output of the `predict` method.
OK the reason is that `IsotonicRegression().predict(X)` call `IsotonicRegression().transform(X)` ;)
I don't know if we should have:

```python
def predict(self, T):
    with config_context(transform_output="default"):
        return self.transform(T)
```

or

```python
def predict(self, T):
    return np.array(self.transform(T), copy=False).squeeze()
```
Another solution would be to have a private `_transform` function called by both `transform` and `predict`. In this way, the `predict` call will not call the wrapper that is around the public `transform` method. I think this is even cleaner than the previous code.
/take