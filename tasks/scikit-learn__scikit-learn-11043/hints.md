Sounds reasonable, particularly since at present,

> From: https://github.com/scikit-learn/scikit-learn/issues/10453
> Some meta-estimators (notably model selection and pipeline tools) will pass a dataframe along as-is to nested estimators.

So this would be just one more step in https://github.com/scikit-learn/scikit-learn/issues/5523 ..

> for strict backwards compatibility, the default should be changed through a deprecation cycle, warning whenever using the default validation means a DataFrame is currently converted to an array.

The warning could say to manually apply `check_array` to get previous behaviour. 
sounds good
Can i work on this?
I should change to `validate=False` in the `__init__()` method and issue a warning inside the `fit()` or `_transform()` method?
we aim to maintain backwards compatibility, so we can't change current
behaviour immediately.

There are two tasks here: creating a new option for validate, documenting
and testing it; and deprecating the current default. Tackle the first task,
then we'll help describe what's needed for the second.

@bmanohar16 are you working on this, or would you like me to take it over? 
@mohamed-ali, you can take over the issue.