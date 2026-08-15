After discussing with @amueller 	, maybe the best option would be to:

- store a seed attribute e.g. `_train_val_split_seed` that would be generated **once**, the first time `fit` is called
- pass this seed as the `random_state`  parameter to `train_test_split()`.
- add a small test making sure this parameter stays constant between different calls to `fit`

This should only be done when warm_start is true, though. So different calls to ``fit`` without warm start should probably use different splits if random state was None or a random state object.
Right.

The problem is that we allow warm_start to be False the first time we fit, and later set it to true with `set_params` :(
Sorry, we should always store the seed, but only re-use it if ``warm_start=True``.
Why do you prefer to store a seed over `get_state()`
At the end of the day, something has to be stored in order to generate the same training and validation sets. An integer is smaller than a tuple returned by `get_state()`, but the difference can probably be overlooked.
If we store a seed we can just directly pass it to `train_test_split`, avoiding the need to create a new RandomState instance.

both are fine with me. 
+1 for storing a seed as fit param and reuse that to seed an rng in fit only when `warm_start=True`.

AFAIK, `np.random.RandomState` accept `uint32` seed only (between `0` and `2**32 - 1`). So the correct way to get a seed from an existing random state object is:

```python
self.random_seed_ = check_random_state(self.random_state).randint(np.iinfo(np.uint32).max)
```
I did something that is not as good for HGBDT:
https://github.com/scikit-learn/scikit-learn/blob/06632c0d185128a53c57ccc73b25b6408e90bb89/sklearn/ensemble/_hist_gradient_boosting/gradient_boosting.py#L142
It would probably be worth changing this as well.

I can work on this if there is no one.
PR welcome @johannfaouzi :)

Also instead of having `_small_trainset_seed` and `_train_val_seed` maybe we can just have one single seed. And I just realized that seed should also be passed to the binmapper that will also subsample.