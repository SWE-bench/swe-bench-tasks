This sounds reasonable to me for `SelectFromModel`.

However `SelectFromModel.transform` is inherited from [`SelectorMixin.transform`](https://github.com/scikit-learn/scikit-learn/blob/a24c8b464d094d2c468a16ea9f8bf8d42d949f84/sklearn/feature_selection/base.py#L62) which is used in other feature selectors. So relaxing this check here, means adding additional checks to the feature selectors that require it, for instance, RFE, [as far as I understand](https://github.com/scikit-learn/scikit-learn/blob/a24c8b464d094d2c468a16ea9f8bf8d42d949f84/sklearn/feature_selection/rfe.py#L235).  Which means that `RFE.predict` would validate `X` twice. The alternative is to copy-paste the transform code from the mixin to `SelectFromModel` which is also not ideal.

I'm not sure if it's worth it; let's wait for a second opinion on this..
I'd be happy if this constraint were removed, even in RFE, where the
downstream model will check for finiteness too, and perhaps univariate
(although then finiteness checks should be implemented in our available
score functions)

I am happy to work on this issue if there is no one else working on it.
I have made an example how it could be fixed. Could you please review it?