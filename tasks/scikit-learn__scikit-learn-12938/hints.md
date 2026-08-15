So for some reason, the class is `PrettyPrinter` instead of `_EstimatorPrettyPrinter` (which inherits from `PrettyPrinter`). But then 

```
  File "/path/to//sklearn/utils/_pprint.py", line 175, in _pprint_estimator
    if self._indent_at_name:
```
is a `_EstimatorPrettyPrinter` method, so I don't understand what is going on...
By the way, the example also fails on master, but somehow circle-ci on master is green.
by example, I mean `examples/compose/plot_compare_reduction.py`
#12791 seems to be failing for the same reason.
> By the way, the example also fails on master, but somehow circle-ci on master is green.

I can't see it in the latest build on master.
I think it's because this line should involve a `.copy()`

https://github.com/scikit-learn/scikit-learn/blob/684d8a221d29ba1659e81961425a2380a9930044/sklearn/utils/_pprint.py#L324
That is, we're modifying the dispatch used by `pprint` rather than the local pretty printer.

But then it's also a bit weird that `_pprint_estimator` references a method on the class. This means that configuration of the class cannot affect anything. Rather it should perhaps reference an instancemethod on a configuration singleton??
@NicolasHug do you want to fix this, or should we open it to other contributors?
Thanks @jnothman I didn't see this, I'll take a look
You're right @jnothman we should make a copy of `_dispatch`.

The bug happens because joblib is using calling `PrettyPrinter` on an estimator, but the `_dispatch` dict of `PrettyPrinter` has been updated by `_EstimatorPrettyPrinter` sometime before, which tells the `PrettyPrinter` object to use `_EstimatorPrettyPrinter._pprint_estimator` to render `BaseEstimator` objects.

Pretty sneaky... I'll submit a fix.


However I'm not sure I follow your concern about `_pprint_estimator` being a method.
Minimal reproducing example:

```
from pprint import PrettyPrinter
from sklearn.linear_model import LogisticRegression

lr = LogisticRegression()
PrettyPrinter().pprint(lr)
```