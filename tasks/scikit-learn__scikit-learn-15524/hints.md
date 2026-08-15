This seems to be because BaseSearchCV doesn't define the _pairwise property. It should, as should other meta-estimators.​
Thanks for the report. A patch is welcome.

@Jeanselme are you working on a fix for this? I've been looking for a good first issue and happen to have done a couple projects with meta-estimators recently
No, I didn’t dig into the code, feel free to fix it. Thank you !
Gotcha. I think I'll give it a shot then 
Thanks!

No problem! I think I might have found a small wrinkle in the plan, though.

Fixing the BaseSearchCV to have the _pairwise property is pretty straightforward and I think I've managed to set it up by just adding the _pairwise property kinda like #11453, or more explicitly just throwing this into BaseSearchCV:

```python
@property
def _pairwise(self):
    # For cross-validation routines to split data correctly
    return self.estimator.metric == 'precomputed'
```


....but I'm worried that doing so won't support someone wanting to compare 'precomputed' with other distance metrics within the same grid search. (e.g. for an exotic square X such as a normalized graph Laplacian matrix)

For example,
```python
from sklearn import datasets
from sklearn.model_selection import cross_val_predict, GridSearchCV
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics.pairwise import euclidean_distances

# Open data
iris = datasets.load_iris()

# Compute pairwise metric
metric = euclidean_distances(iris.data)

# Create nested cross validation
knn = KNeighborsClassifier()
knngs = GridSearchCV(knn, param_grid={"n_neighbors": [1, 5, 10], "metric":["euclidean", "precomputed"]}, cv=10)
predicted = cross_val_predict(knngs, metric, iris.target, cv=10)
```

This code would throw the same error even with the _pairwise fix in BaseSearchCV unless `knn = KNeighborsClassifier(metric='precomputed')`. However, forcing the base_estimator to have `metric='precomputed'` _will be inherited to all of the other estimators during search_, and  this will result in incorrectly slicing non-precomputed metrics during [`_safe_split`.](https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/utils/metaestimators.py) 

We might have to disable precomputed distance metrics from being used jointly in a BaseSearchCV, if we just add a _pairwise property to it, otherwise I think we'd have to modify either [`_safe_split`](https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/utils/metaestimators.py) or [`evaluate_candidates`](https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/utils/metaestimators.py) in to simultaneously support 'precomputed' and other metrics.
We could certainly just take the easy way of adding the _pairwise property to BaseSearchCV and barring simultaneous searches of 'precomputed' with other distance metrics. Of course, someone else might see a better way to support simultaneity.

Any thoughts/preferences?
I think this is closer to the mark:
```py
@property
def _pairwise(self):
    # For cross-validation routines to split data correctly
    return getattr(self.estimator, '_pairwise', False)
```

> I'm worried that doing so won't support someone wanting to compare 'precomputed' with other distance metrics within the same grid search.

I don't think that's reasonable in the sense that the precomputed input has completely different semantics (columns are samples) to non-precomputed (columns are features). 
That is a good point. I'll adjust the code I've written based on your advice and submit when I can 