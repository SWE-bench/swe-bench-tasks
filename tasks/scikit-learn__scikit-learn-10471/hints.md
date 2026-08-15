Can you give an example?
Maybe we should then rather change the behavior in KMeans.
I wouldn't change the output format, since we don't know what the user wants to do next.

They should be the same that the output and input format of PCA.fit_transform, isn't it?
Because PCA.transform is such.

In _k_means._assign_labels_array, the ddot will be very slow, when X is Fortran data.

``` Python
    for sample_idx in range(n_samples):
        min_dist = -1
        for center_idx in range(n_clusters):
            dist = 0.0
            # hardcoded: minimize euclidean distance to cluster center:
            # ||a - b||^2 = ||a||^2 + ||b||^2 -2 <a, b>
            dist += ddot(n_features, &X[sample_idx, 0], x_stride,
                         &centers[center_idx, 0], center_stride)
```

I have a large sample set, before the dimension reduction, each iteration only need a little more than a minute, but need to be 7 minute after dimension reduction.

2 important questions:
- How general is the requirement to be C contiguous? It speeds up for
  k-means, but will it not slow down for other algorithms?
- Can the change be made in k-means rather than in PCA? If you are not
  using copy_X=False, I don't see any argument for not making the change
  in k-means, and I would much prefer it.

- I just think it is a natural idea that the features of a sample are stored in a row.
- I don't know how to speeds up for k-means, in the case of using Fortran data. :(
- copy_X=False. This reduces the memory usage, but without speeds up for k-means. Anyway I like it too.

>   • I just think it is a natural idea that the features of a sample are stored in a row.

I think that you are assuming too much.

>   • I don't know how to speeds up for k-means, in the case of using Fortran
>     data. :(

It's just a question of calling "np.ascontiguousarray" on the array when
making the copy.

>   • copy_X=False. This reduces the memory usage,

OK. We would have to do a copy here.

I am opposed to changing the behavior of PCA without a more exhausive
review of what it implies speedwise in the codebase: what algorithms
perform best with C or Fortran ordered data.

Ok, I agree with you, and thank you for your explanation.

@zhaipro I think it would be appreciated if you could benchmark k-means with different memory layouts and see how it performs. We could change the memory layout there, which would solve your problem. Btw, you might be interested in this PR #2008 which will make k-means quite a bit faster.

benchmark:
C order time: 1.370000 inertia: 422652.759578
F order time: 6.536000 inertia: 422652.759578

I have a large sample set, so that the `precompute_distances = False`, 
by the following code in k_means:

``` Python
if precompute_distances == 'auto':
    n_samples = X.shape[0]
    precompute_distances = (n_clusters * n_samples) < 12e6
```

Here, To show my problem, I set directly `precompute_distances = False`.

``` Python
import numpy as np
from sklearn.cluster import KMeans
from time import time

def bench_kmeans(name, data):
    start = time()
    km = KMeans(n_clusters=200, init='random', n_init=1, max_iter=1,
                copy_x=False, random_state=42, precompute_distances=False).fit(data)
    print("%s time: %f inertia: %f" % (name, time() - start, km.inertia_))


np.random.seed(0)
data = np.random.random(3000*1000).reshape((3000, 1000))
# for C order
bench_kmeans(name='C order', data=data)
# for F order
data = np.asfortranarray(data)
bench_kmeans(name='F order', data=data)
```

Is that true for slim and fat data and different number of clusters? Also, have you tried the elkan branch?

Cool, for elkan alg.
@amueller However, it requires more memory?

```
('shape:', (3000, 1000))
n_clusters  alg name    time    inertia:
50  lloyd   C order 0.426000    453724.729456
50  lloyd   F order 1.782000    453724.729456
50  elkan   C order 0.588000    244227.752545
50  elkan   F order 0.652000    244227.752545
100 lloyd   C order 0.744000    442351.514140
100 lloyd   F order 3.488000    442351.514140
100 elkan   C order 0.892000    239220.149899
100 elkan   F order 0.942000    239220.149899
200 lloyd   C order 1.401000    422652.759578
200 lloyd   F order 6.694000    422652.759578
200 elkan   C order 1.608000    229660.875075
200 elkan   F order 1.632000    229660.875075
('shape:', (1000, 3000))
n_clusters  alg name    time    inertia:
50  lloyd   C order 0.510000    453021.642152
50  lloyd   F order 1.416000    453021.642152
50  elkan   C order 0.630000    236247.135296
50  elkan   F order 0.692000    236247.135296
100 lloyd   C order 1.042000    427321.624518
100 lloyd   F order 2.580000    427321.624518
100 elkan   C order 1.152000    222766.273428
100 elkan   F order 1.212000    222766.273428
200 lloyd   C order 1.908000    378199.959299
200 lloyd   F order 5.046000    378199.959299
200 elkan   C order 1.964000    196655.300444
200 elkan   F order 2.069000    196655.300444
```

``` Python
import numpy as np
from sklearn.cluster import KMeans
from time import time
from itertools import product

def bench_kmeans(name, data, alg, n_clusters):
    start = time()
    km = KMeans(algorithm=alg, n_clusters=n_clusters, init='random', n_init=1, max_iter=1,
                copy_x=False, random_state=42, precompute_distances=False).fit(data)
    print("%d\t%s\t%s\t%f\t%f" % (n_clusters, alg, name, time() - start, km.inertia_))


def test_kmeans(data):
    c_data = data
    f_data = np.asfortranarray(data)
    print('n_clusters\talg\tname\ttime\tinertia:')
    for n_clusters, alg, (name, data) in product((50, 100, 200),
                                    ('lloyd', 'elkan'),
                                     zip(('C order', 'F order'), (c_data, f_data))):
        bench_kmeans(name=name, data=data, alg=alg, n_clusters=n_clusters)

np.random.seed(0)
data = np.random.random(3000*1000).reshape((3000, 1000))
print('shape:', data.shape)
test_kmeans(data)
data = data.reshape((1000, 3000))
print('shape:', data.shape)
test_kmeans(data)
```

Thanks a lot for the benchmark.
I'm quite surprised at the difference in inertia between the two implementations... maybe I messed up the stopping criterion again?
The memory requirement for elkan shouldn't be substantial.

It looks to me like for lloyd (the current implementation) we should `copy("C")` by default (or rather do that in `check_array`
I'm not sure if we should make this optional or add a parameter. I think I'd actually not add a parameter but just add to the docs "the data will be converted to C ordering, which might cause a memory copy if the data is given in fortran order" something like that.

> I'm quite surprised at the difference in inertia between the two implementations...

@amueller I think maybe the reason is that I have only one iteration.

makes sense.

Can someone give me a little explanation of what needs to be done for this issue? Since it seems like the issue description (of title was later updated), perhaps the issue description was not updated.

In particular, there is term ['C contiguous'](https://www.ibm.com/support/knowledgecenter/SSAT4T_14.1.0/com.ibm.xlf141.linux.doc/language_ref/contiguous.html) (probably right link) what does that refer, is that fortran term? machine learning term? or [numpy.ascountiguous](https://docs.scipy.org/doc/numpy-1.14.0/reference/generated/numpy.ascontiguousarray.html).

Also if a summary of issue discussion can be given it had be great (since following the issue discussion is a little confusing for me). I'm assuming that this issue needs work, even though the PR https://github.com/scikit-learn/scikit-learn/pull/5414 was merged, which seems to be for accelerating K means algorithm.
Summary: KMeans, when using check_array, should declare order='C'.

See https://docs.scipy.org/doc/numpy-1.12.0/glossary.html#term-row-major