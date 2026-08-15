Not sure if we want to do this for 0.20.1 as a bugfix?
If the target is multiclass and labels is None or includes all present
labels, I agree it would be less confusing if micro is hidden or is
labelled "accuracy". I don't mind making this a fix for 0.20.x, but it's
not worth blocking on.

Hi, 
Is this issue being worked on? I'm a beginner and I'd like to contribute (if needed) - kindly let me know if anything's up. Thanks!
@anjalibhavan sure go for it!
Hi, are there any news on this issue? Has a Pull Request been made? I would like to contribute too!
Yes there is a pr in #12353
Looks like this was introduced in #9303 so @wallygauze should probably take a look too.
I haven't checked in-depth how incremental pca does partial fits, but does it really need `n_components` to be <= to the `batch_size` (`n_samples` in partial_fit) - especially does it need this to hold for _every_ batch? Or should the actual requirement be in `fit` that `n_components <= n_samples` (all of them, not a single batch) and possibly also `n_components <= batch_size` (so that at least one batch is big enough)?

In any case, I don't think dropping the last batch if it is too small is a good solution - it might be an important part of the data.
Looked like a bug and a regression to me
anyone looking into this for 0.20.1?
I don't know of anyone working on it, but I would consider it a blocker for
0.20.1 as it's an important regression that should not be hard to fix

Hi, if this issue is still open for a fix, will try to look at this issue and produce a PR. 👍 