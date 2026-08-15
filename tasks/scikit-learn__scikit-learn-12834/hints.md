Is numeric-only an intentional limitation in this case? There are lines that explicitly cast to double (https://github.com/scikit-learn/scikit-learn/blob/e73acef80de4159722b11e3cd6c20920382b9728/sklearn/ensemble/forest.py#L279). It's not an issue for single-output models, though.
Sorry what do you mean by "DV"?
You're using the regressors:
FOREST_CLASSIFIERS_REGRESSORS

They are not supposed to work with classes, you want the classifiers.

Can you please provide a minimum self-contained example?
Ah, sorry. "DV" is "dependent variable". 

Here's an example:
```
X_train = [[-2, -1], [-1, -1], [-1, -2], [1, 1], [1, 2], [2, 1], [-2, 1],
               [-1, 1], [-1, 2], [2, -1], [1, -1], [1, -2]]
y_train = [["red", "blue"], ["red", "blue"], ["red", "blue"], ["green", "green"],
               ["green", "green"], ["green", "green"], ["red", "purple"],
               ["red", "purple"], ["red", "purple"], ["green", "yellow"],
               ["green", "yellow"], ["green", "yellow"]]
X_test = [[-1, -1], [1, 1], [-1, 1], [1, -1]]
est = RandomForestClassifier()
est.fit(X_train, y_train)
y_pred = est.predict(X_test)
```

Returns:
```
---------------------------------------------------------------------------
ValueError                                Traceback (most recent call last)
<ipython-input-5-a3b5313a012b> in <module>
----> 1 y_pred = est.predict(X_test)

~/repos/forks/scikit-learn/sklearn/ensemble/forest.py in predict(self, X)
    553                 predictions[:, k] = self.classes_[k].take(np.argmax(proba[k],
    554                                                                     axis=1),
--> 555                                                           axis=0)
    556
    557             return predictions

ValueError: could not convert string to float: 'green'
```
Thanks, this indeed looks like bug.

The multi-output multi-class support is fairly untested tbh and I'm not a big fan of it (we don't implement ``score`` for that case!).
So even if we fix this it's likely you'll run into more issues. I have been arguing for removing this feature for a while (which is probably not what you wanted to hear ;)
For what it's worth, I think this specific issue may be resolved with a one-line fix. For my use case, having `predict` and `predict_proba` work is all I need.
Feel free to submit a PR if you like