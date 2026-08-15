It would help if you provide some data (whether or not it gives that warning) for which the implementations give different results
(the stack overflow implementation won't work if your labels are not (0, 1, ..., n clusters - 1)
Mmmh the labels are generated from MiniBatchKMeans so I _think_ they should be correct.

I managed to produce a [minimum working example](https://drive.google.com/open?id=1KtkkfTecNf5gvj8Jvxi-h2vifZLxO3mX). 
The feature matrix is still 500MB, sorry about that.

The output of the example is the following:

```
/home/luca/.local/lib/python3.7/site-packages/sklearn/metrics/cluster/unsupervised.py:342: RuntimeWarning: divide by zero encountered in true_divide
  score = (intra_dists[:, None] + intra_dists) / centroid_distances
Davies-Bouldin score [0 is best]: 2.7680860797941347
Custom Davies-Bouldin score [0 is best]: 0.0883489022177005

```
> I managed to produce a minimum working example. The feature matrix is still 500MB, sorry about that.

An interesting definition of minimum :)
It was in terms of code needed.
I'll try to reduce the size in the next days!
The same issue can be reproduced for `measure_quality(samples[::200], labels[::200])` and I'm sure the dataset can be reduced much further.
But the difference is in:
* ours: `np.mean(np.nanmax(score, axis=1))`
* theirs: `np.max(db) / n_cluster`

If we use `np.max(score) / n_labels` we get the same result as the SO answer.

I think the Accepted Answer in stack overflow is incorrect, and disagrees with other implementations posted there. Please review the formula in the paper and confirm my analysis.
Thank you for your analysis!

Yes, you are right. In the paper (freely available [here](https://www.researchgate.net/publication/224377470_A_Cluster_Separation_Measure)) it computes the average of the scores:

![image](https://user-images.githubusercontent.com/11019190/48737903-94ee0b00-ec4f-11e8-8008-7bebb487ed84.png)


So, I'm not sure about what's happening, does the warning about division by 0  mean that there are two different clusters with the same centroid?

The warning is unrelated to the discrepancy. It is happening in the division 
Feel free to down-vote the stack overflow answer or up vote my comment there
I'm also getting this warning every time I run this metric. The warning is being caused by dividing by a matrix returned by `pairwise_distances`, which is defined as:
> A distance matrix D such that D_{i, j} is the distance between the ith and jth vectors of the given matrix X, if Y is None. If Y is not None, then D_{i, j} is the distance between the ith array from X and the jth array from Y.

Therefore, any element where i = j will be 0 as this would be the distance from the ith cluster center to the ith cluster center. Looking at the following lines, it is apparent that this behavior is expected and handled:
```python
score[score == np.inf] = np.nan
return np.mean(np.nanmax(score, axis=1))
```
Since this is expected behavior and is handled correctly (as far as I can tell), I would reccomend that we suppress the warning with `with np.errstate(divide='ignore'):`. I can submit the pull request but I wanted to confirm that this is intentional behavior before I do so. Please let me know.
If it's a degenerate case it might be worthwhile raising a warning, albeit a more specific one.

Since we need to cleanse the output of division in any case, we might as well avoid the non-threadsafe context manager and instead just set problematic denominators to 1.
And yes, a pull request is very welcome
It would help if you provide some data (whether or not it gives that warning) for which the implementations give different results
(the stack overflow implementation won't work if your labels are not (0, 1, ..., n clusters - 1)
Mmmh the labels are generated from MiniBatchKMeans so I _think_ they should be correct.

I managed to produce a [minimum working example](https://drive.google.com/open?id=1KtkkfTecNf5gvj8Jvxi-h2vifZLxO3mX). 
The feature matrix is still 500MB, sorry about that.

The output of the example is the following:

```
/home/luca/.local/lib/python3.7/site-packages/sklearn/metrics/cluster/unsupervised.py:342: RuntimeWarning: divide by zero encountered in true_divide
  score = (intra_dists[:, None] + intra_dists) / centroid_distances
Davies-Bouldin score [0 is best]: 2.7680860797941347
Custom Davies-Bouldin score [0 is best]: 0.0883489022177005

```
> I managed to produce a minimum working example. The feature matrix is still 500MB, sorry about that.

An interesting definition of minimum :)
It was in terms of code needed.
I'll try to reduce the size in the next days!
The same issue can be reproduced for `measure_quality(samples[::200], labels[::200])` and I'm sure the dataset can be reduced much further.
But the difference is in:
* ours: `np.mean(np.nanmax(score, axis=1))`
* theirs: `np.max(db) / n_cluster`

If we use `np.max(score) / n_labels` we get the same result as the SO answer.

I think the Accepted Answer in stack overflow is incorrect, and disagrees with other implementations posted there. Please review the formula in the paper and confirm my analysis.
Thank you for your analysis!

Yes, you are right. In the paper (freely available [here](https://www.researchgate.net/publication/224377470_A_Cluster_Separation_Measure)) it computes the average of the scores:

![image](https://user-images.githubusercontent.com/11019190/48737903-94ee0b00-ec4f-11e8-8008-7bebb487ed84.png)


So, I'm not sure about what's happening, does the warning about division by 0  mean that there are two different clusters with the same centroid?

The warning is unrelated to the discrepancy. It is happening in the division 
Feel free to down-vote the stack overflow answer or up vote my comment there
I'm also getting this warning every time I run this metric. The warning is being caused by dividing by a matrix returned by `pairwise_distances`, which is defined as:
> A distance matrix D such that D_{i, j} is the distance between the ith and jth vectors of the given matrix X, if Y is None. If Y is not None, then D_{i, j} is the distance between the ith array from X and the jth array from Y.

Therefore, any element where i = j will be 0 as this would be the distance from the ith cluster center to the ith cluster center. Looking at the following lines, it is apparent that this behavior is expected and handled:
```python
score[score == np.inf] = np.nan
return np.mean(np.nanmax(score, axis=1))
```
Since this is expected behavior and is handled correctly (as far as I can tell), I would reccomend that we suppress the warning with `with np.errstate(divide='ignore'):`. I can submit the pull request but I wanted to confirm that this is intentional behavior before I do so. Please let me know.
If it's a degenerate case it might be worthwhile raising a warning, albeit a more specific one.

Since we need to cleanse the output of division in any case, we might as well avoid the non-threadsafe context manager and instead just set problematic denominators to 1.
And yes, a pull request is very welcome