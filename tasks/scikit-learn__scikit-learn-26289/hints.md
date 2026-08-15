Could you please post a minimal reproducible? (something we can copy paste in its entirety to produce the issue).
@NickKanellos From the error message, it seems that the feature names you passed in is an array, but as [documented](https://scikit-learn.org/stable/modules/generated/sklearn.tree.export_graphviz.html), `feature_names` must either be a list of strings or `None`.

> feature_nameslist of str, default=None
Names of each of the features. If None, generic names will be used (“x[0]”, “x[1]”, …).