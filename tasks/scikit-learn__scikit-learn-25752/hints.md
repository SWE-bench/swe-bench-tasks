Thanks for the reproducible example.

`KMeans` **does** weight the data, but your example is an extreme case. Because `Kmeans` is a non-convex problem, the algorithm can get stuck in a local minimum, and not find the true minimum  of the optimization landscape. This is the reason why the code proposes to use multiple initializations, hoping that some initializations will not get stuck in poor local minima.

Importantly, **the initialization does not use sample weights**. So when using `init="k-means++"` (default), it gets a centroid on the outliers, and `Kmeans` cannot escape this local minimum, even with strong sample weights.

Instead, the optimization does not get stuck if we do one of the following changes:
- the outliers are less extremes (e.g. 10 instead of 100), because it allows the sample weights to remove the local minimum
- the low samples weights are exactly equal to zero, because it completely discard the outliers
- using `init="random"`, because some of the different init are able to avoid the local minimum
If we have less extreme weighting then ```init='random'``` does not work at all as shown in this example. The centers are always [[3.],[40.]] instead of circa [[1.],[5.]] for the weighted case.
```py
import numpy as np
from sklearn.cluster import KMeans
x = np.array([1, 1, 5, 5, 40, 40])
w = np.array([100,100,100,100,1,1]) # large weights for 1 and 5, small weights for 40
x=x.reshape(-1,1)# reshape to a 2-dimensional array requested for KMeans
centers_with_weight = KMeans(n_clusters=2, random_state=0,n_init=100,init='random').fit(x,sample_weight=w).cluster_centers_
centers_no_weight = KMeans(n_clusters=2, random_state=0,n_init=100).fit(x).cluster_centers_
```
Sure, you can find examples where `init="random"` also fails.
My point is that `KMeans` is non-convex, so it is never guaranteed to find the global minimum.

That being said, **it would be nice to have an initialization that uses the sample weights**. I don't know about `init="k-means++"`, but for `init="random"` we could use a non-uniform sampling relative to the sample weights, instead of the current uniform sampling.

Do you want to submit a pull-request?
yes
I want to work on this issue
Was this bug already resolved?
Not resolved yet, you are welcome to submit a pull-request if you'd like.
I already answered this question by "yes" 3 weeks ago. 