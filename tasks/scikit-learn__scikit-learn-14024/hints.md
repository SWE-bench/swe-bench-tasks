I am just adding the traceback


```pytb
---------------------------------------------------------------------------
ZeroDivisionError                         Traceback (most recent call last)
<ipython-input-3-b0953fbb1d6e> in <module>
----> 1 clf.fit(X, y)

~/Documents/code/toolbox/scikit-learn/sklearn/ensemble/_hist_gradient_boosting/gradient_boosting.py in fit(self, X, y)
    247                     min_samples_leaf=self.min_samples_leaf,
    248                     l2_regularization=self.l2_regularization,
--> 249                     shrinkage=self.learning_rate)
    250                 grower.grow()
    251 

~/Documents/code/toolbox/scikit-learn/sklearn/ensemble/_hist_gradient_boosting/grower.py in __init__(self, X_binned, gradients, hessians, max_leaf_nodes, max_depth, min_samples_leaf, min_gain_to_split, max_bins, actual_n_bins, l2_regularization, min_hessian_to_split, shrinkage)
    195         self.total_compute_hist_time = 0.  # time spent computing histograms
    196         self.total_apply_split_time = 0.  # time spent splitting nodes
--> 197         self._intilialize_root(gradients, hessians, hessians_are_constant)
    198         self.n_nodes = 1
    199 

~/Documents/code/toolbox/scikit-learn/sklearn/ensemble/_hist_gradient_boosting/grower.py in _intilialize_root(self, gradients, hessians, hessians_are_constant)
    260             return
    261         if sum_hessians < self.splitter.min_hessian_to_split:
--> 262             self._finalize_leaf(self.root)
    263             return
    264 

~/Documents/code/toolbox/scikit-learn/sklearn/ensemble/_hist_gradient_boosting/grower.py in _finalize_leaf(self, node)
    399         """
    400         node.value = -self.shrinkage * node.sum_gradients / (
--> 401             node.sum_hessians + self.splitter.l2_regularization)
    402         self.finalized_leaves.append(node)
    403 

ZeroDivisionError: float division by zero
```
At a glance, the softmax is bringing probabilities close enough to zero, which causes hessians to be zero for the cross entropy loss.
I think the right fix is just to add a small epsilon to the denominator to avoid the zero division.

As Thomas noted these cases happen when the trees are overly confident in their predictions and will always predict a probability of 1 or 0, leading to stationary gradients and zero hessians.

We hit this part of the code in `initialize_root()`:
```py
        if sum_hessians < self.splitter.min_hessian_to_split:
            self._finalize_leaf(self.root)
            return
```

and since hessians are zero `finalize_leaf()` fails.

That's because the learning rate is too high BTW.
Changing the learning rate to .05 I get a .67 accuracy (not bad over 100 classes).


Will submit a PR soon