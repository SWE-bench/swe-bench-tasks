You might have expected [nan, 1, 1,] too. We raise a warning to tell you that we will set it to 0.
I think the problem is that we do not raise a warning when there's only negative labels. E.g.
```python
precision_score([0, 0, 0], [0, 0, 0])
```
I vote for a warning to tell users that we set precision, recall, fbeta_score and support to 0 in this case. 
Yes, that's an issue.

But that's not the issue here. The complaint is that if y_true and y_pred
are equal, precision_score should always be 1.
​
A warning is indeed raised for the snippet presented in the issue
description.

> A warning is indeed raised for the snippet presented in the issue description.

Sorry, I haven't noticed that.

So my opinion here is:
(1) Keep the current behavior as I suppose there's no clear definition of precision_score when there's only negative labels.
(2) Also raise similar warning for ``precision_score([0, 0, 0], [0, 0, 0])``
Maybe raising a warning like "XXX is ill-defined and being set to 0.0 where there is only one label in both true and predicted samples." where XXX would be precision/recall/f_score and returning 0 could be added when there is only label in both y_true and y_pred.

It could be added right after this, when `present_labels.size == 1` and XXX would be determined by the argument  `warn_for`.

https://github.com/scikit-learn/scikit-learn/blob/158c7a5ea71f96c3af0ea611304d57e4d2ba4994/sklearn/metrics/classification.py#L1027-L1030
Currently, `precision_score([0, 0, 0], [0, 0, 0])` returns 1. If 0 is returned, some tests fail (1 is expected) like test_averaging_multilabel_all_ones :
https://github.com/scikit-learn/scikit-learn/blob/4e87d93ce6fae938aa366742732b59a730724c73/sklearn/metrics/tests/test_common.py#L937-L946

and check_averaging calls _check_averaging :
https://github.com/scikit-learn/scikit-learn/blob/4e87d93ce6fae938aa366742732b59a730724c73/sklearn/metrics/tests/test_common.py#L833-L838

The multilabel case returns 1 and the current binary case returns also 1 (and returns 0 if the changes are made).

Are these tests supposed to be modified thus? @qinhanmin2014 