`Ridge` and `LinearRegression` are not classifiers, which makes them incompatible with `VotingClassifier`.
> Ridge and LinearRegression are not classifiers, which makes them incompatible with VotingClassifier.

+1 though maybe we should return a better error message.
Shall we check the base estimators with `sklearn.base.is_classifier` in the `VotingClassifier.__init__` or `fit` and raise a `ValueError`? 
> Shall we check the base estimators with sklearn.base.is_classifier in the VotingClassifier.__init__ or fit and raise a ValueError?

We have something similar for the StackingClassifier and StackingRegressor.

Actually, these 2 classes shared something in common by having `estimators` parameters. In some way they are an ensemble of "heterogeneous" estimators (i.e. multiple estimators) while bagging, RF, GBDT is an ensemble of "homogeneous" estimator (i.e. single "base_estimator").

We could have a separate base class for each type. Not sure about the naming but it will reduce code redundancy and make checking easier and consistent.