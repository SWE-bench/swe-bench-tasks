When you say prevent, do you mean that we should raise an error if
n_quantiles > n_samples, or that we should adjust n_quantiles to
min(n_quantiles, n_samples)? I'd be in favour of the latter, perhaps with a
warning. And yes, improved documentation is always good (albeit often
ignored).

I was only talking about the documentation but yes we should also change the behavior when n_quantiles > n_samples, which will require a deprecation cycle... Ideally the default of n_quantiles should be n_samples. And if too slow users can choose a n_quantiles value smaller than n_samples.
I don't think the second behavior (when `n_quantiles=200`, which leads to a linear interpolation that does not correspond to the numpy.percentile(X_train, .) estimator) is the intended behavior. Unless someone tells me there is a valid reason behind it.
> Therefore I don't think we should be able to choose n_quantiles > n_samples and we should prevent users from thinking that the higher n_quantiles the better the transformation.

+1 for dynamically downgrading n_quantiles to "self.n_quantiles_ = min(n_quantiles, n_samples)" maybe with a warning.

However, -1 for raising an error: people might not know in advance what the sample is.


Sounds good! I will open a PR.