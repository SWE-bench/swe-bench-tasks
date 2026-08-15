From a quick glance at your description it seems like you have a good grasp of what is happening and it could well be a bug (I am not a Lasso expert so don't take my word for it). 

It would help a lot if you could provide a stand-alone snippet to reproduce the problem. Please read http://matthewrocklin.com/blog/work/2018/02/28/minimal-bug-reports for more details.

You could also look at `git blame` or if that's easier the [equivalent thing](https://github.com/scikit-learn/scikit-learn/blame/master/sklearn/linear_model/coordinate_descent.py#L1235) through github and figure out if there was a good motivation historically for setting `model.precompute = False`.

Hm. According to the git-blame it was changed from being set to `'auto'` to `False` simply because auto was "found to be slower even when num_samples > num_features". I can say this is definitely not true for my data-set. Furthermore this is inconsistent with other LASSOs in sklearn, which of course default to auto - including all of the LASSOs which run in the grid-search leading up to this point in LassoCV.

This occurred back in 2014. It's pretty astounding to me that no one else has encountered this issue. I can't provide my proprietary data, but I am able to reproduce the issue by simply running:

```
from sklearn.datasets import make_regression
from sklearn.linear_model import LassoCV

X, y = make_regression(n_samples=10000000, n_features=400)
model = LassoCV()
model.fit(X, y)
```
I can not run your snippet because I don't have enough RAM on my computer (`X` needs about 30GB of RAM), does the same problem happens for e.g. 10 times less data?

The ideal thing to do would be to do a benchmark similar to https://github.com/scikit-learn/scikit-learn/pull/3249#issuecomment-57908917 first to see if you can reproduce the same kind of curves and also with higher `n_samples` to convince potential reviewers that your proposed change (which I think is essentially `model.precompute = self.precompute` which is what https://github.com/scikit-learn/scikit-learn/pull/3249#discussion_r18430919 hints at) is better.

Just in case, maybe @agramfort or @ogrisel have some insights or informed suggestions off the top of their heads. To sum up for them: in LassoCV once all the cross-validation folds have been performed, `LassoCV.fit()` always sets `precompute = False` before refitting on the full (training + validation) data.  In other words, the `precompute` set in the `LassoCV` constructor is only used for the fits on the training data and not on the final fit. Historically it looks like setting `precompute=True` for the last final fit was always faster, but it seems like this is not always true.


yes we should not overwrite the precompute param.

PR welcome

I looked at this in a little bit more details and it feels like we may need to revisit #3249. If I run the snippet from https://github.com/scikit-learn/scikit-learn/pull/3220#issuecomment-44810510 for example (which showed that precompute=False was faster than precompute=True) I actually get the opposite ordering on my machine (scikit-learn version 0.19.1):

```py
from sklearn.datasets import make_regression
from sklearn.linear_model import ElasticNet
from sklearn.linear_model import ElasticNetCV
X, y = make_regression(n_samples=10000, n_features=50)
for precompute in [False, True]:
    print('precompute={}'.format(precompute))
    %timeit ElasticNet(precompute=precompute).fit(X, y)
```

Output:
```
precompute=False
8.24 ms ± 67.7 µs per loop (mean ± std. dev. of 7 runs, 100 loops each)
precompute=True
6.26 ms ± 207 µs per loop (mean ± std. dev. of 7 runs, 100 loops each)
```

For reference this is with MKL but I tried with the wheels using OpenBLAS and although the numbers differ slightly, `precompute=True` is faster than `precompute=False` with OpenBLAS too.
@Meta95 I would still be interested by a snippet that is closer to your use case and that I can run on my machine. This would be very helpful to try to understand the problem further.

Full disclosure: I tried a few different things but the final fit was never the bottleneck, in contrary to what you are seeing, so I may be missing something.
@lesteve Thanks for looking into it and checking out my pull request! It's a bit of a pain that it isn't as easy as removing the `self.precompute = False` line. 

I wish I could provide something closer to my use-case that you could run. However I think this is just a constraint of your machine - how could you run against a data-set larger than your memory? In the meantime I have ran your script with larger parameters (10000000, 500) on the high-memory server I'm using. Here's the output:

```
precompute=False
1 loop, best of 3: 2min 36s per loop
precompute=True
1 loop, best of 3, 1min 50s per loop
```

Still not the kind of discrepancy I'm seeing with my data. But it should be clear by now that there's no reason to override precompute as it does provide better performance.
It looks like "auto" was deprecated partially. I don't understand what happened exactly but it looks like we messed up the removal of "auto":
https://github.com/scikit-learn/scikit-learn/pull/5528

It's removed from ElasticNet and Lasso but not from their path functions, and not from LassoCV and ElasticNetCV where it is overwritten (as complained about in this issue).
looks like the mess originates here:
https://github.com/amueller/scikit-learn/commit/140a5acda8e44384f8e072e2d50a1d28a798cded

maybe @lesteve or @agramfort can comment on that, I'm not sure what the intent was.
Sorry I misunderstood the code. "auto" is actually used in the CV models for the path, but it's not available for fitting the final model.
So I would argue we should either use the same heuristic here, or replace "auto" by False.