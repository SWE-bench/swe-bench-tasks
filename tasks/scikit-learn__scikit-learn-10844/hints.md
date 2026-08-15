That seems a good idea. How does it compare to converting pk or qk to
float, in terms of preserving precision? Compare to calculating in log
space?

On 10 August 2017 at 11:07, Manh Dao <notifications@github.com> wrote:

> Description
>
> sklearn\metrics\cluster\supervised.py:859 return tk / np.sqrt(pk * qk) if
> tk != 0. else 0.
> This line produces RuntimeWarning: overflow encountered in int_scalars
> when (pk * qk) is bigger than 2**32, thus bypassing the int32 limit.
> Steps/Code to Reproduce
>
> Any code when pk and qk gets too big.
> Expected Results
>
> Be able to calculate tk / np.sqrt(pk * qk) and return a float.
> Actual Results
>
> it returns 'nan' instead.
> Fix
>
> I propose to use np.sqrt(tk / pk) * np.sqrt(tk / qk) instead, which gives
> same result and ensuring not bypassing int32
> Versions
>
> 0.18.1
>
> —
> You are receiving this because you are subscribed to this thread.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/9515>, or mute the
> thread
> <https://github.com/notifications/unsubscribe-auth/AAEz6xHlzfHsuKN94ngXEpm1UHWfhIZlks5sWlfugaJpZM4Oy0qW>
> .
>

At the moment I'm comparing several clustering results with the fowlkes_mallows_score, so precision isn't my concern. Sorry i'm not in a position to rigorously test the 2 approaches.
could you submit a PR with the proposed change, please?

On 11 Aug 2017 12:12 am, "Manh Dao" <notifications@github.com> wrote:

> At the moment I'm comparing several clustering results with the
> fowlkes_mallows_score, so precision isn't my concern. Sorry i'm not in a
> position to rigorously test the 2 approaches.
>
> —
> You are receiving this because you commented.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/9515#issuecomment-321563119>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz64f0j7CW1sLufawWhwQo1LMnRm0Vks5sWw_TgaJpZM4Oy0qW>
> .
>

or code to reproduce?
I just ran into this and it looks similar to another [issue](https://github.com/scikit-learn/scikit-learn/issues/9772) in the same module (which I also ran into). The [PR](https://github.com/scikit-learn/scikit-learn/pull/10414) converts to int64 instead. I tested both on 4.1M pairs of labels and the conversion to int64 is slightly faster with less variance:

```python
%timeit sklearn.metrics.fowlkes_mallows_score(labels_true, labels_pred, sparse=False)
726 ms ± 3.83 ms per loop (mean ± std. dev. of 7 runs, 1 loop each)
```

for the int64 conversion vs.

```python
%timeit sklearn.metrics.fowlkes_mallows_score(labels_true, labels_pred, sparse=False)
739 ms ± 7.57 ms per loop (mean ± std. dev. of 7 runs, 1 loop each)
```

for the float conversion.

```diff
diff --git a/sklearn/metrics/cluster/supervised.py b/sklearn/metrics/cluster/supervised.py
index a987778ae..43934d724 100644
--- a/sklearn/metrics/cluster/supervised.py
+++ b/sklearn/metrics/cluster/supervised.py
@@ -856,7 +856,7 @@ def fowlkes_mallows_score(labels_true, labels_pred, sparse=False):
     tk = np.dot(c.data, c.data) - n_samples
     pk = np.sum(np.asarray(c.sum(axis=0)).ravel() ** 2) - n_samples
     qk = np.sum(np.asarray(c.sum(axis=1)).ravel() ** 2) - n_samples
-    return tk / np.sqrt(pk * qk) if tk != 0. else 0.
+    return tk / np.sqrt(pk.astype(np.int64) * qk.astype(np.int64)) if tk != 0. else 0.


 def entropy(labels):
```

Shall I submit a PR?