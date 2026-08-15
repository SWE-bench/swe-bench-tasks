I tried this in Jupyter on windows. It is working fine. Also, I tried one more thing. 
The IsolationForest algorithm expects the input data to have column names (i.e., feature names) when it is fitted. If you create a DataFrame without column names, the algorithm may not work as expected. In your case, the X DataFrame was created without any column names (may be sklearn is not recognizing "a"). To fix this, you can add column names to the DataFrame when you create it

```
from sklearn.ensemble import IsolationForest
import pandas as pd

X = pd.DataFrame({"a": [-1.1, 0.3, 0.5, 100]}, columns = ['a'])
clf = IsolationForest(random_state=0, contamination=0.05).fit(X)
```
This is a bug indeed, I can reproduce on 1.2.2 and `main`, thanks for the detailed bug report!
The root cause as you hinted:
- `clf.fit` is called with a `DataFrame` so there are some feature names in
- At the end of `clf.fit`, when `contamination != 'auto'` we call `clf.scores_samples(X)` but `X` is now an array
  https://github.com/scikit-learn/scikit-learn/blob/9260f510abcc9574f2383fc01e02ca7e677d6cb7/sklearn/ensemble/_iforest.py#L348
- `clf.scores_samples(X)` calls `clf._validate_data(X)` which complains since `clf` was fitted with feature names but `X` is an array
  https://github.com/scikit-learn/scikit-learn/blob/9260f510abcc9574f2383fc01e02ca7e677d6cb7/sklearn/ensemble/_iforest.py#L436

Not sure what the best approach is here, cc @glemaitre and @jeremiedbb who may have suggestions.
OK. What if we pass the original feature names to the clf.scores_samples() method along with the input array X. You can obtain the feature names used during training by accessing the feature_names_ attribute of the trained IsolationForest model clf.

```
# Assuming clf is already trained and contamination != 'auto'
X = ...  # input array that caused the error
feature_names = clf.feature_names_  # get feature names used during training
scores = clf.score_samples(X, feature_names=feature_names)  # pass feature names to scores_samples()
```
In https://github.com/scikit-learn/scikit-learn/pull/24873 we solved a similar problem (internally passing a numpy array when the user passed in a dataframe). I've not looked at the code related to `IsolationForest` but maybe this is a template to use to resolve this issue.
It seems like this approach could work indeed, thanks! 

To summarise the idea would be to:
- add a `_scores_sample` method without validation
- have `scores_sample` validate the data and then call `_scores_sample`
- call `_scores_sample` at the end of `.fit`

I am labelling this as "good first issue", @abhi1628, feel free to start working on it if you feel like it! If that's the case, you can comment `/take` and the issue, see more info about contributing [here](https://scikit-learn.org/dev/developers/contributing.html#contributing-code)
Indeed, using a private function to validate or not the input seems the way to go.
Considering the idea of @glemaitre and @betatim I tried this logic. 


```
import numpy as np
import pandas as pd
from sklearn.ensemble import IsolationForest

def _validate_input(X):
    if isinstance(X, pd.DataFrame):
        if X.columns.dtype == np.object_:
            raise ValueError("X cannot have string feature names.")
        elif X.columns.nunique() != len(X.columns):
            raise ValueError("X contains duplicate feature names.")
        elif pd.isna(X.columns).any():
            raise ValueError("X contains missing feature names.")
        elif len(X.columns) == 0:
            X = X.to_numpy()
        else:
            feature_names = list(X.columns)
            X = X.to_numpy()
    else:
        feature_names = None
    if isinstance(X, np.ndarray):
        if X.ndim == 1:
            X = X.reshape(-1, 1)
        elif X.ndim != 2:
            raise ValueError("X must be 1D or 2D.")
        if feature_names is None:
            feature_names = [f"feature_{i}" for i in range(X.shape[1])]
    else:
        raise TypeError("X must be a pandas DataFrame or numpy array.")
    return X, feature_names

def _scores_sample(clf, X):
    return clf.decision_function(X)

def scores_sample(X):
    X, _ = _validate_input(X)
    clf = IsolationForest()
    clf.set_params(**{k: getattr(clf, k) for k in clf.get_params()})
    clf.fit(X)
    return _scores_sample(clf, X)

def fit_isolation_forest(X):
    X, feature_names = _validate_input(X)
    clf = IsolationForest()
    clf.set_params(**{k: getattr(clf, k) for k in clf.get_params()})
    clf.fit(X)
    scores = _scores_sample(clf, X)
    return clf, feature_names, scores
```
Please modify the source code and add a non-regression test such that we can discuss implementation details. It is not easy to do that in an issue.
Hi, I'm not sure if anyone is working on making a PR to solve this issue. If not, can I take this issue?
@abhi1628 are you planning to open a Pull Request to try to solve this issue?

If not, @Charlie-XIAO you would be more than welcome to work on it.
Thanks, I will wait for @abhi1628's reponse then.
I am not working on it currently, @Charlie-XIAO
<https://github.com/Charlie-XIAO> you can take this issue. Thank You.

On Wed, 22 Mar, 2023, 12:59 am Yao Xiao, ***@***.***> wrote:

> Thanks, I will wait for @abhi1628 <https://github.com/abhi1628>'s reponse
> then.
>
> —
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/25844#issuecomment-1478467224>,
> or unsubscribe
> <https://github.com/notifications/unsubscribe-auth/ANIBKQBDKOSP2V2NI2NEM2DW5H6RXANCNFSM6AAAAAAVZ2DOAA>
> .
> You are receiving this because you were mentioned.Message ID:
> ***@***.***>
>

Thanks, will work on it soon.
/take