thanks for the report. ping @pprett ?

Observation:
The estimators with feature importance sum 0 have only 1 node which is being caused by the following [code](https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/tree/_tree.pyx#L228-L229)
`is_leaf = (is_leaf or (impurity <= min_impurity_split))`

`is_leaf` is changing to 1 in the first iteration for such trees.

For estimator number 710
`impurity = 0.00000010088593634382
min_impurity_split = 0.00000010000000000000`

For estimator number 711 (which has 0 feature importance sum)
`impurity = 0.00000009983122597550
min_impurity_split = 0.00000010000000000000`

The same behavior is there for all subsequent estimators.

Versions:
Ubuntu 16.04, Python: 2.7.10, Numpy: 1.11.2, Scipy: 0.18.1, Scikit-Learn: 0.19.dev0

ping @jmschrei maybe?

If the gini impurity at the first node is that low, you're not gaining anything by having more trees. I am unsure if this is a bug, except that it should maybe only look at the impurity of trees where a split improves things. 

So should these extra trees (containing only one node) be considered while computing feature importance?

@Naereen skipping them would be fine I guess, and would make them sum to one again?

IMO, while computing trees, when gini impurity of the first node of a tree is lower than the threshold, the program shouldn't move forward. The actual number of trees computed should be communicated to the user. In example above, program should stop at 711 and number of estimators should be 710.

on master, the first part of the issue seems fixed. This part of the code now returns 1.0 as expected.
```python
feature_importance_sum = np.sum(clf.feature_importances_)
print("At n_estimators = %i, feature importance sum = %f" % (n_estimators , feature_importance_sum))
```
It has been fixed in #11176.
However, for the second part of the issue, the problem is still present. the trees that add up to 0.0 actually contain only 1 node and `feature_importances_` does not really make sens for those trees. Maybe something should be done to avoid having those trees.
By 1 node, you mean just a single leaf node, or a single split node? Yes, a tree with a single leaf node should not be contributing to feature importances.
1 is the value returned by `node_count`. According to the docstring, it's internal nodes + leaves. So those trees are just a single leaf node.