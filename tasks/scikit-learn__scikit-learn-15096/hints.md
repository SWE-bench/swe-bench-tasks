A solution could be to clone the estimator after set_param call in _fit_and_score, and return the new cloned estimator. However it would break any function that use _fit_and_score and expect to keep using the same estimator instance than passed in _fit_and_score..
Hmm... I agree this is a bit of an issue. But I think it is reflecting a
design issue with the estimator you are setting parameters of: it should
probably be cloning its parameters before fitting them if they did not
already come in fitted. Yes, our Pipeline and FeatureUnion are guilty of
this and it's a bit of a problem. We've been trying to work out how to
change it and not break too much code.

I'll have to think about what risks we'd take by cloning when setting
parameters. It's an interesting proposal. Certainly, users could have taken
advantage of this fact to allow estimators to accept pre-fitted models. And
it's long-standing behaviour, so I wouldn't want to break it without
warning...

I just spent hours trying to get to the bottom of some strange behavior and errors related to grabbing pipelines from cv_results_ and just realized this is likely the issue, when params are estimator objects they are all fitted and it causes weird errors when you try to reuse the pipeline.  In my case the first error was with StandardScaler() and getting the ValueError cannot broadcast... shape... yada.

I can give you a major use case for getting pipelines from cv_results_, I am using the nice GridSearchCV functionality to not only optimize estimator hyperparameters but also compare and optimize different pipeline step combos (thanks @jnothman for helping me with questions on implementing that a while back).  After it runs I interrogate cv_results_ to determine the best scores of each pipeline type combo and was grabbing those pipelines from cv_results_['params'] to run them each on held out test data to also get test scores.  When calling decision_function() or predict_proba() I was getting errors I didn't understand until now.

Either way it's not a work stoppage issue for me, I can simply use the original non-fitted estimator combos I passed in the param_grid to GridSearchCV in the first place.  Thanks though @fcharras making me realize what was wrong!

@hermidalc can you please open an issue with a reproducible example?
Student just came to me with this behavior being very confused. It looks like the estimators that are stored don't correspond to the same split, which is weird.

I'll have a minimum example soon.

I think cloning here would be the right thing to do, and I would call it a bug fix.
The only way a user could have used it here is using a meta-estimator with a prefit estimator, right?
I guess this would be a hacky work-around for being able to cross-validate something with a prefit estimator, but I feel like this is not a route we should encourage.

Maybe we can discuss this at the sprint?
Though on the other hand, this is part of the freezing discussion. If we can freeze, we can clone in the pipeline and then all is good...
```python
import numpy as np
import pandas as pd

from sklearn.linear_model import LinearRegression, Ridge
from sklearn.compose import make_column_transformer
from sklearn.preprocessing import OneHotEncoder 
from sklearn.impute import SimpleImputer
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.pipeline import Pipeline

housing = pd.read_excel("http://www.amstat.org/publications/jse/v19n3/decock/AmesHousing.xls", nrows=500)

y = housing['SalePrice']
X = housing.drop(columns=['SalePrice', 'Order', 'PID'])

categorical = X.dtypes == object
X.loc[:, categorical] = X.loc[:, categorical].fillna("NaN")

X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=0)

transform = make_column_transformer(
    (SimpleImputer(strategy="median"), ~categorical),
    (OneHotEncoder(handle_unknown="ignore"), categorical)
)

pipe = Pipeline([
    ('transformer', transform),
    ('regressor', LinearRegression())
])
param_grid = {'regressor': [LinearRegression(), Ridge()]}

grid = GridSearchCV(pipe, param_grid, cv=10)
grid.fit(X_train, y_train)

print("Number of Linear Regression Weights: {}" \
      .format(len(grid.cv_results_['param_regressor'][0].coef_)))

print("Number of Ridge Regression Weights: {}" \
      .format(len(grid.cv_results_['param_regressor'][1].coef_)))
```
> 258
> 260

I have no idea what's going on here, looks like the Imputer drops different numbers of columns or the OneHotEncoder sees different categories. But that shouldn't really happen, right? Also, this is deterministic.
Why shouldn't OneHotEncoder see different categories?

@jnothman because the order of CV folds is deterministic and the categories don't depend on whether ridge or lr is used, right?
Not sure if this helps, but I've been dealing with what seems to be the same, and have isolated the problem to the `clone` method, used [here](https://github.com/scikit-learn/scikit-learn/blob/7813f7efb/sklearn/model_selection/_validation.py#L779) inside of `cross_val_predict` and [here](https://github.com/scikit-learn/scikit-learn/blob/7813f7efb/sklearn/model_selection/_validation.py#L227) inside of cross_validate.

```
from sklearn.base import is_classifier, clone
pipe2 = clone(pipe)
first = pipe.fit_transform(train[features], train[target]).shape
second = pipe2.fit_transform(train[features], train[target]).shape
print(first)
>>> (16000, 245)
print(second)
>>> (16000, 13)
```

If this is relevant I can attempt to do an end-to-end example. 
I'm not sure it's relevant to the current issue, but you could certainly
open a new issue with a complete, reproducible example.

You are right, I tried it on the AmesHousing example and did not reproduce. Will open a separate one.  
@PedroGFonseca could you ever reproduce?
Ah, I understand now: the one that is selected will be refit, so ``grid.cv_results_['param_regressor'][0]`` is the one fitted on the last fold in cross-validation, while ``grid.cv_results_['param_regressor'][1]`` is actually ``grid.best_estimator_``.

There should definitely be some cloning here somewhere (cc @thomasjpfan lol)