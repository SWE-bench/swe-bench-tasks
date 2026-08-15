The `__repr__` is not defined in the `_RepeatedSplit` class from which these cross-validation are inheriting. A possible fix should be:

```diff
diff --git a/sklearn/model_selection/_split.py b/sklearn/model_selection/_split.py
index ab681e89c..8a16f68bc 100644
--- a/sklearn/model_selection/_split.py
+++ b/sklearn/model_selection/_split.py
@@ -1163,6 +1163,9 @@ class _RepeatedSplits(metaclass=ABCMeta):
                      **self.cvargs)
         return cv.get_n_splits(X, y, groups) * self.n_repeats
 
+    def __repr__(self):
+        return _build_repr(self)
+
 
 class RepeatedKFold(_RepeatedSplits):
     """Repeated K-Fold cross validator.
```

We would need to have a regression test to check that we print the right representation.
Hi @glemaitre, I'm interested in working on this fix and the regression test. I've never contributed here so I'll check the contribution guide and tests properly before starting.
Thanks @DrGFreeman, go ahead. 
After adding the `__repr__` method to the `_RepeatedSplit`, the `repr()` function returns `None` for the `n_splits` parameter. This is because the `n_splits` parameter is not an attribute of the class itself but is stored in the `cvargs` class attribute.

I will modify the `_build_repr` function to include the values of the parameters stored in the `cvargs` class attribute if the class has this attribute.