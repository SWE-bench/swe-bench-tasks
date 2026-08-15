Is that MissingIndicator failing? Shouldn't it be silent if a feature has
nan in test but is not one of the features or provides indicators for?

If we set `MissingIndicator`'s `error_on_new=False`, then it will be silent. Currently, there is not a way to directly set this from `SimpleImputer`'s API.
We should have error_on_new=False by default for add_indicator.
