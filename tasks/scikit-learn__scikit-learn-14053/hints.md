Thanks for the report. A patch is welcome.
@jnothman Obviously, `feature_names` should have the same length as the number of features in the dataset, which in this reported issue, `feature_names` should be of length 4. 

Do you hope to fix this bug by adding a condition in the `if feature_names` statement, such as `if feature_names and len(feature_names)==decision_tree.n_features_`, or do you have other ideas? I can take this issue after I understand how you want to fix this bug. Thank you
Here only one feature of Iris is used. I've not investigated the bug in detail yet.
@fdas3213 indeed only one feature used as I only selected the first columns in X: `X[:, 0].reshape(-1, 1)`. I also tried to use two features: `X[:, 0:2].reshape(-1, 1)` and then passed a two-item list to `feature_names`. No exception raised. This issue only happens when you have a single feature.

@StevenLi-DS Thanks for the feedback. I'll try this on few more datasets and features. 
It's so strange that when I call `export_text` without adding `feature_names` argument, such as `tree_text = export_tree(tree)`, it works properly, and `export_text` will print feature names as `feature_0` as indicated in the export.py.  However, when I access `tree.tree_.feature`, it gives an array with values `0` and `-2`, like `array([0, 0, -2, 0, -2, ...])`; shouldn't this array contain only one unique value since the dataset X passed to `DecisionTreeClassifier()` contains only one column?
-2 indicates a leaf node, which does not split on a feature

Since `feature_names` is a single item list, accessing this list using `0` and `-2` caused the error. Maybe should consider removing `-2` from `tree_.feature` so that `tree_.feature` contains only `0`?
export_tree should never be accessing the feature name for a leaf

Exactly, but in line 893, `feature_names = [feature_names[i] for i in tree_.feature]`, where 
`tree_.feature = array([ 0,  0, -2,  0, -2,  0, -2,  0, -2,  0, -2,  0, -2, -2,  0,  0,  0,
       -2,  0, -2, -2,  0, -2,  0, -2,  0, -2, -2,  0,  0,  0, -2,  0,  0,
        0, -2, -2, -2,  0, -2,  0,  0, -2, -2, -2, -2, -2], dtype=int64)`. So it's obviously accessing -2(leaf node), and that's why this bug happens?

Which means that the problem is not in the index, but in the control flow
that allows that statement to be executed.
