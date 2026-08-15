As noted in the [glossery](https://scikit-learn.org/dev/glossary.html#term-transform), Scikit-learn transformers expects that `transform`'s output have the same number of samples as the input. This exception is held in `FeatureUnion` when processing data and tries to make sure that the output index is the same as the input index. In principle, we can have a less restrictive requirement and only set the index if it is not defined.

To better understand your use case, how do you intend to use the `FeatureUnion` in the overall pipeline?


> Scikit-learn transformers expects that transform's output have the same number of samples as the input

I haven't known that. Good to know. What is the correct way to aggregate or drop rows in a pipeline? Isn't that supported?

> To better understand your use case, how do you intend to use the FeatureUnion in the overall pipeline?

The actual use case: I have a time series (`price`) with hourly frequency. It is a single series with a datetime index. I have built a dataframe with pipeline and custom transformers (by also violating the rule to have same number of inputs and outputs) which aggregates the data (calculates daily mean, and some moving average of daily means) then I have transformed back to hourly frequency (using same values for all the hours of a day). So the dataframe has (`date`, `price`, `mean`, `moving_avg`) columns at that point with hourly frequency ("same number input/output" rule violated again). After that I have added the problematic `FeatureUnion`. One part of the union simply drops `price` and "collapses" the remaining part to daily data (as I said all the remaining columns has the same values on the same day). On the other part of the feature union I calculate a standard devition between `price` and `moving_avg` on daily basis. So I have the (`date`, `mean`, `moving_avg`) on the left side of the feature union and an `std` on the right side. Both have daily frequency. I would like to have a dataframe with (`date`, `mean`, `moving_avg`, `std`) at the end of the transformation.
As I see there is the same "problem" in `ColumnTransfromer`.
I have a look at how `scikit-learn` encapsulates output into a `DataFrame` and found this code block:

https://github.com/scikit-learn/scikit-learn/blob/main/sklearn/utils/_set_output.py#L55-L62

Is there any reason to set index here? If transformer returned a `DataFrame` this already has some kind of index. Why should we restore the original input index? What is the use case when a transformer changes the `DataFrame`'s index and `scikit-learn` has to restore it automatically to the input index?

With index restoration it is also expected for transformers that index should not be changed (or if it is changed by transformer then `scikit-learn` restores the original one which could be a bit unintuitive). Is this an intended behaviour?

What is the design decision to not allow changing index and row count in data by transformers? In time series problems I think it is very common to aggregate raw data and modify original index.