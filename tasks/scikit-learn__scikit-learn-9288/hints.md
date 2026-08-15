Looks like the `n_jobs=1` case gets a different random seed for the `n_init` runs than the `n_jobs!=1` case.

https://github.com/scikit-learn/scikit-learn/blob/7a2ce27a8f5a24db62998d444ed97470ad24319b/sklearn/cluster/k_means_.py#L338-L363

I'll submit a PR that sets `random_state` to be the same in both cases. 
I've not chased down the original work, but I think this was intentional when we implemented n_jobs for KMeans initialisation, to avoid backwards incompatibility. Perhaps it makes more sense to be consistent within a version than across, but that is obviously a tension. What do you think?
I seem to remember a discussion like this before (not sure it was about `KMeans`). Maybe it would be worth trying to search issues and read the discussion there. 
@jnothman I looked back at earlier KMeans-related issues&mdash;#596 was the main conversation I found regarding KMeans parallelization&mdash;but couldn't find a previous discussion of avoiding backwards incompatibility issues. 

I definitely understand not wanting to unexpectedly alter users' existing KMeans code. But at the same time, getting a different KMeans model (with the same input `random_state`) depending on if it is parallelized or not is unsettling.  

I'm not sure what the best practices are here. We could modify the KMeans implementation to always return the same model, regardless of the value of `n_jobs`. This option, while it would cause a change in existing code behavior, sounds pretty reasonable to me. Or perhaps, if the backwards incompatibility issue make it a better option to keep the current implementation, we could at least add a note to the KMeans API documentation informing users of this discrepancy. 
yes, a note in the docs is a reasonable start.

@amueller, do you have an opinion here?

Note this was reported in #9287 and there is a WIP PR at #9288. I see that you have a PR at https://github.com/scikit-learn/scikit-learn/pull/9785 and your test failures do look intriguing ...
okay. I think I'm leaning towards fixing this to prefer consistency within rather than across versions... but I'm not sure.
@lesteve oops, I must have missed #9287 before filing this issue. Re: the `test_gaussian_mixture` failures for #9785, I've found that for `test_warm_start`, if I increase `max_iter` to it's default value of 100, then the test passes. That is, 

```python
# Assert that by using warm_start we can converge to a good solution
g = GaussianMixture(n_components=n_components, n_init=1,
                    max_iter=100, reg_covar=0, random_state=random_state,
                    warm_start=False, tol=1e-6)
h = GaussianMixture(n_components=n_components, n_init=1,
                    max_iter=100, reg_covar=0, random_state=random_state,
                    warm_start=True, tol=1e-6)

with warnings.catch_warnings():
    warnings.simplefilter("ignore", ConvergenceWarning)
    g.fit(X)
    h.fit(X).fit(X)

assert_true(not g.converged_)
assert_true(h.converged_)
```

passes. I'm not sure why the original value of `max_iter=5` was chosen to begin with, maybe someone can shed some light onto this. Perhaps it was just chosen such that the 

```python
assert_true(not g.converged_)
assert_true(h.converged_)
```
condition passes? I'm still trying to figure out what's going on with `test_init` in `test_gaussian_mixture`. 
I think consistency within a version would be better than across versions.