This has nothing to do with TransformedTargetRegressor. Pipeline requires
you to pass model__sample_weight, not just sample_weight... But the error
message is terrible! We should improve it.

Thank you for your prompt reply @jnothman 

### Second try : 
```python
clf_trans.fit(X_train[use_col], y_train,
              model__sample_weight=X_train['weight']
             )

---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
<ipython-input-25-aa3242bb1603> in <module>()
----> 1 clf_trans.fit(df[use_col], y, model__sample_weight=df['sample_weight'])

TypeError: fit() got an unexpected keyword argument 'model__sample_weight'
```

Did i miss something or anything ?

By the way I used this kind of pipeline typo (don't know how to call it) in `GridSearchCV` and it work's well !

```python
from sklearn.model_selection import GridSearchCV

param_grid = { 
    'regressor__model__n_estimators': [20, 50, 100, 200]
}

GDCV = GridSearchCV(estimator=clf_trans, param_grid=param_grid, cv=5,
                    n_jobs=-1, scoring='neg_mean_absolute_error',
                    return_train_score=True, verbose=True)
GDCV.fit(X[use_col], y)
```

Ps : Fill free to rename title if it can help community
You're right. we don't yet seem to properly support fit parameters in TransformedTargetRegressor. And perhaps we should...
> This has nothing to do with TransformedTargetRegressor. Pipeline requires you to pass model__sample_weight, not just sample_weight... But the error message is terrible! We should improve it.

That's true but what @armgilles asked in the first example was the sample_weight, a parameter that it's passed in the fit call. From my knowledge, specifying model__sample_weight just sets internal attributes of the model step in the pipeline but doesn't modify any parameters passed to the fit method

Should we implement both parameters, meaning the parameter of the model (like we do in GridSearchCV) and parameter of the fit (eg. sample_weight, i don't know if there are more that could be passed in fit call) ?
No, the comment *is* about fit parameters. TransformedTargetRegressor
currently accepts sample_weight, but to support pipelines it needs to
support **fit_params

Cool, I'll give it a try then
I am having the same problem here using the `Pipeline` along with `CatBoostRegressor`. The only hacky way I found so far to accomplish this is to do something like:
```
pipeline.named_steps['reg'].regressor.set_params(**fit_params)
# Or alternatively 
pipeline.set_params({"reg_regressor_param": value})
```
And then call 
```
pipeline.fit(X, y)
```

Where `reg` is the step containing the `TransformedTargetRegressor`. is there a cleaner way? 
That's not about a fit parameter like sample_weight at all. For that you
should be able to set_params directly from the TransformedTargetRegressor
instance. Call its get_params to find the right key.

@jnothman thanks for your response . Please let me know if I am doing something wrong. From what I understand there are 3 issues here:


1.  `TransformedTargetRegressor` fit only passes sample_weight to the underlying regressor. Which you can argue that's what is has to do. Other estimators, (not sklearn based but compatible). might  support receiving other  prams in the `fit` method. 

2. `TransformedTargetRegressor` only support sample_weight as a parameter and d[oes not support passing arbitrary parameters](https://github.com/scikit-learn/scikit-learn/blob/1495f69242646d239d89a5713982946b8ffcf9d9/sklearn/compose/_target.py#L200-L205) to the underlying `regressor` fit method as `Pipeline` does (i.e. using `<component>__<parameter>` convention ). 

3. Now, when using a Pipeline  and I want to pass a parameter to the regressor inside a `TransformedTargetRegressor` at fit time this fails. 

Some examples:

```python
from sklearn.pipeline import Pipeline
from sklearn.compose import TransformedTargetRegressor
from catboost import CatBoostRegressor 
import numpy as np

tr_regressor = TransformedTargetRegressor(
            CatBoostRegressor(),
             func=np.log, inverse_func=np.exp
)

pipeline = Pipeline(steps=[
              ('reg', tr_regressor)
])

X = np.arange(4).reshape(-1, 1)
y = np.exp(2 * X).ravel()

pipeline.fit(X, y, reg__regressor__verbose=False)
---
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
     17 y = np.exp(2 * X).ravel()
     18 
---> 19 pipeline.fit(X, y, reg__regressor__verbose=False)

~/development/order_prediction/ord_pred_env/lib/python3.6/site-packages/sklearn/pipeline.py in fit(self, X, y, **fit_params)
    354                                  self._log_message(len(self.steps) - 1)):
    355             if self._final_estimator != 'passthrough':
--> 356                 self._final_estimator.fit(Xt, y, **fit_params)
    357         return self
    358 

TypeError: fit() got an unexpected keyword argument 'regressor__verbose'
```

This also fails:

```python
pipeline.named_steps['reg'].fit(X, y, regressor__verbose=False)

---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
<ipython-input-19-fd09c06db732> in <module>
----> 1 pipeline.named_steps['reg'].fit(X, y, regressor__verbose=False)

TypeError: fit() got an unexpected keyword argument 'regressor__verbose'
```

This actually works:

```python
pipeline.named_steps['reg'].regressor.fit(X, y, verbose=False)
```
And this will also work:
```python
pipeline.set_params(**{'reg__regressor__verbose': False})
pipeline.fit(X, y)
```

So I have a question:

Shouldn't `TransformedTargetRegressor` `fit` method support `**fit_params` as the `Pipeline`does? i.e. passing parameters to the underlying regressor via the `<component>__<parameter>` syntax? 

Maybe I missing something or  expecting something from the API I should not be expecting here. Thanks in advance for the help :). 




I think the discussion started from the opposite way around: using a `Pipeline `as the `regressor `parameter of the `TransformedTargetRegressor`. The problem is the same: you cannot pass fit parameters to the underlying regressor apart from the `sample_weight`.

Another question is if there are cases where you would want to pass fit parameters to the transformer too because the current fit logic calls fit for the transformer too.
>  The problem is the same: you cannot pass fit parameters to the
underlying regressor apart from the sample_weight.

Yes, let's fix this and assume all fit params should be passed to the
regressor.

> Another question is if there are cases where you would want to pass fit
parameters to the transformer too because the current fit logic calls fit
for the transformer too.

We'll deal with this in the world where
https://github.com/scikit-learn/enhancement_proposals/pull/16 eventually
gets completed, approved, merged and implemented!!

Pull request welcome.

i will start working 