Are you thinking a lasso_kwargs parameter?
yeah, more like `algorithm_kwargs` I suppose, to cover `Lasso`, `LassoLars`, and `Lars`

But I was looking at the code to figure how many parameters are not covered by what's already given to `SparseCoder`, and there's not many. In fact, `max_iter` is a parameter to `SparseCoder`, not passed to `LassoLars` (hence the warning I saw in the example), and yet used when `Lasso` is used.

Looks like the intention has been to cover the union of parameters, but some may be missing, or forgotten to be passed to the underlying models.
Then just fixing it to pass to LassoLars seems sensible
