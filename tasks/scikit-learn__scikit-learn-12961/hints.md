Thanks for reporting the issue. Could you please also include a [minimal and reproducible example](http://sscce.org/) for us to better diagnose the problem?
Hi - yes I'll try to find one, unfortunately the dataset I'm working on has some licensing restrictions, so will need to reproduce it with something else. 
I figured out why. It's triggered by a pretty silly bug in my code - my CV iterator was exhausted when I tried to use it again. This resulted a fail somewhere after calling `rs.fit(x, y)`, i.e. there was no result returned (`out is None`) for the `format_results()` method to unpack. 

Perhaps the better fix would be to assert that the CV iterator passed to `cv=` in the constructor, if not None, isn't empty?

Thinking about this again, this would happen when the estimator used produces fails to produced the expected output for whatever reason. The most useful thing to do would be to produce a better error or warning message?

Thanks. 

Sent from my iPhone

> On 23 Dec 2018, at 00:02, Adrin Jalali <notifications@github.com> wrote:
> 
> Thanks for reporting the issue. Could you please also include a minimal and reproducible example for us to better diagnose the problem?
> 
> —
> You are receiving this because you authored the thread.
> Reply to this email directly, view it on GitHub, or mute the thread.

Failing estimators are handled in _fit_and_score, so I don't think that's a
problem. Checking and raising an appropriate error if the splitter returns
an empty iterator seems a good idea.

Let me look into testing for empty iterator and come back in a week or so. 
I think checking for empty `out` here seems appropriate:
https://github.com/scikit-learn/scikit-learn/blob/8d7e849428a4edd16c3e2a7dc8a088f108986a17/sklearn/model_selection/_search.py#L673

@jnothman 

Thanks for the pointer, something like this? Pls feel free to suggest a better error message. I did not explicitly put empty CV iterator as a reason here as there may be other causes for an estimator to return None, which isn't great but could happen...

```
no_result_check = [x is None for x in out]
if np.any(no_result_check):
    raise ValueError('Estimator returned no result (None)')
```

You really need to implement a test. I don't think your proposed snippet will solve the problem.

I think you want something like
```py
if not out:
    raise ValueError('No fits were performed. Was the CV iterator empty? Were there no candidates?')
```

A variant we could consider is:
```py
if len(out) != n_candidates * n_splits:
    raise ValueError('cv.split and cv.get_n_splits returned inconsistent results. Expected {} splits, got {}'.format(n_splits, len(out) // n_candidates))
```
finally getting around to this, will spend some time in the next couple of days for a PR. 