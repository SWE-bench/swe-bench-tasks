Indeed, `Nystroem` uses the kernel parameter in two ways:
- in `sklearn.metrics.pairwise.pairwise_kernels`, which does accept `metric='precomputed'`
- in `sklearn.metrics.pairwise.KERNEL_PARAMS`, which does not contain a "precomputed" key.

This is a bug, "precomputed" should be added in `KERNEL_PARAMS`, and we also need a non-regression test.

Thanks for the report ! Do you want to fix it ?
I would like to work on this. can I take this up?
Yes, go ahead, I did not have time so far to look at it.

I am unsure, since I have not studied the theory, but maybe there is a bigger issue with the Nystroem implementation:

Giving `n` features to Nystroem, it still produces `n` features with `.fit_transform`, only now the features are of a different dimensionality (`n_components`). I was hoping Nystroem would actually only store/compute a kernel matrix of `n_components` x `n`. (see storage and complexity: https://en.wikipedia.org/wiki/Low-rank_matrix_approximations#Nystr%C3%B6m_approximation)

In its current state, it seems you still reach a `n` x `n` kernel matrix, which defeats the purpose of using Nystroem, right? For example, Nystroem should make it possible to do Kernel Ridge Regression with many training examples (large `n`), which would typically be very expensive.

Maybe I misunderstand how it is supposed to work. The example on scikit-learn actually increases the dimensionality of the features from 64 to 300: https://scikit-learn.org/stable/modules/generated/sklearn.kernel_approximation.Nystroem.html#sklearn.kernel_approximation.Nystroem which seems like a strange example to me. The score is improved, but this is not an application where memory or complexity is reduced.
