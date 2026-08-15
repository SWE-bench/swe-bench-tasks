Thanks for the clear issue description. Your diagnosis is not quite correct. The error is made when `labels` is a prefix of the available labels.

This is probably my fault, and I apologise.

The problem is the combination of https://github.com/scikit-learn/scikit-learn/blob/4f710cdd088aa8851e8b049e4faafa03767fda10/sklearn/metrics/classification.py#L1056, https://github.com/scikit-learn/scikit-learn/blob/4f710cdd088aa8851e8b049e4faafa03767fda10/sklearn/metrics/classification.py#L1066, and https://github.com/scikit-learn/scikit-learn/blob/4f710cdd088aa8851e8b049e4faafa03767fda10/sklearn/metrics/classification.py#L1075. We should be slicing `y_true = y_true[:, :n_labels]` in any case that `n_labels < len(labels)`, not only when `np.all(labels == present_labels)`.

Would you like to offer a PR to fix it?
Can I take this up?
Sure, go for it