`check_class_weight_balanced_linear_classifier` is run at tests/test_common.
```
git grep check_class_weight_balanced_linear_classifier
sklearn/tests/test_common.py:    check_class_weight_balanced_linear_classifier)
sklearn/tests/test_common.py:        yield _named_check(check_class_weight_balanced_linear_classifier,
sklearn/utils/estimator_checks.py:def check_class_weight_balanced_linear_classifier(name, Classifier):
```

I can implement a test for `check_class_weight_balanced_classifiers` if that is what we want.
yeah that's what we want