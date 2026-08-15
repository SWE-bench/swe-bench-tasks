In my opinion, yes.

I wanted to compare K-Means, GMM and HDBSCAN and was very disappointed that GMM does not have a `fit_predict` method. The HDBSCAN examples use `fit_predict`, so I was expecting GMM to have the same interface.
I think we should add ``fit_predict`` at least. I wouldn't rename ``n_components``.
I would like to work on this!
@Eight1911 go for it. It is probably relatively simple but maybe not entirely trivial.
@Eight1911 Mind if I take a look at this?
@Eight1911 Do you mind if I jump in as well?