Same results with python 3.5 :

```
Darwin-15.6.0-x86_64-i386-64bit
Python 3.5.1 (v3.5.1:37a07cee5969, Dec  5 2015, 21:12:44) 
[GCC 4.2.1 (Apple Inc. build 5666) (dot 3)]
NumPy 1.11.0
SciPy 0.18.1
Scikit-Learn 0.17.1
```

It happens only with euclidean distance and can be reproduced using directly `sklearn.metrics.pairwise.euclidean_distances` :

```
import scipy
import sklearn.metrics.pairwise

# create 64-bit vectors a and b that are very similar to each other
a_64 = np.array([61.221637725830078125, 71.60662841796875,    -65.7512664794921875],  dtype=np.float64)
b_64 = np.array([61.221637725830078125, 71.60894012451171875, -65.72847747802734375], dtype=np.float64)

# create 32-bit versions of a and b
a_32 = a_64.astype(np.float32)
b_32 = b_64.astype(np.float32)

# compute the distance from a to b using sklearn, for both 64-bit and 32-bit
dist_64_sklearn = sklearn.metrics.pairwise.euclidean_distances([a_64], [b_64])
dist_32_sklearn = sklearn.metrics.pairwise.euclidean_distances([a_32], [b_32])

np.set_printoptions(precision=200)

print(dist_64_sklearn)
print(dist_32_sklearn)
```

I couldn't track down further the error.
I hope this can help.


numpy might use a higher precision accumulator. yes, it looks like this
deserves fixing.

On 19 Jul 2017 12:05 am, "nvauquie" <notifications@github.com> wrote:

> Same results with python 3.5 :
>
> Darwin-15.6.0-x86_64-i386-64bit
> Python 3.5.1 (v3.5.1:37a07cee5969, Dec  5 2015, 21:12:44)
> [GCC 4.2.1 (Apple Inc. build 5666) (dot 3)]
> NumPy 1.11.0
> SciPy 0.18.1
> Scikit-Learn 0.17.1
>
> It happens only with euclidean distance and can be reproduced using
> directly sklearn.metrics.pairwise.euclidean_distances :
>
> import scipy
> import sklearn.metrics.pairwise
>
> # create 64-bit vectors a and b that are very similar to each other
> a_64 = np.array([61.221637725830078125, 71.60662841796875,    -65.7512664794921875],  dtype=np.float64)
> b_64 = np.array([61.221637725830078125, 71.60894012451171875, -65.72847747802734375], dtype=np.float64)
>
> # create 32-bit versions of a and b
> a_32 = a_64.astype(np.float32)
> b_32 = b_64.astype(np.float32)
>
> # compute the distance from a to b using sklearn, for both 64-bit and 32-bit
> dist_64_sklearn = sklearn.metrics.pairwise.euclidean_distances([a_64], [b_64])
> dist_32_sklearn = sklearn.metrics.pairwise.euclidean_distances([a_32], [b_32])
>
> np.set_printoptions(precision=200)
>
> print(dist_64_sklearn)
> print(dist_32_sklearn)
>
> I couldn't track down further the error.
> I hope this can help.
>
> —
> You are receiving this because you are subscribed to this thread.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/9354#issuecomment-316074315>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz65yy8Aq2FcsDAcWHT8qkkdXF_MfPks5sPLu_gaJpZM4OXbpZ>
> .
>

I'd like to work on this if possible 
Go for it!
So I think the problem lies around the fact that we are using `sqrt(dot(x, x) - 2 * dot(x, y) + dot(y, y))` for computing euclidean distance 
Because if I try - ` (-2 * np.dot(X, Y.T) + (X * X).sum(axis=1) + (Y * Y).sum(axis=1)` I get the answer 0 for np.float32, while I get the correct ans for np.float 64.
@jnothman What do you think I should do then ? As mentioned in my comment above the problem is probably computing euclidean distance using `sqrt(dot(x, x) - 2 * dot(x, y) + dot(y, y))`
So you're saying that dot is returning a less precise result than product-then-sum?
No, what I'm trying to say is dot is returning more precise result than product-then-sum
`-2 * np.dot(X, Y.T) + (X * X).sum(axis=1) + (Y * Y).sum(axis=1)` gives output  `[[0.]]`
while `np.sqrt(((X-Y) * (X-Y)).sum(axis=1))` gives output `[ 0.02290595]`
It is not clear what you are doing, partly because you are not posting a fully stand-alone snippet.

Quickly looking at your last post the two things you are trying to compare `[[0.]]` and `[0.022...]` do not have the same dimensions (maybe a copy and paste problem but again hard to know because we don't have a full snippet).
Ok sorry my bad
```
import numpy as np
import scipy
from sklearn.metrics.pairwise import check_pairwise_arrays, row_norms
from sklearn.utils.extmath import safe_sparse_dot

# create 64-bit vectors a and b that are very similar to each other
a_64 = np.array([61.221637725830078125, 71.60662841796875,    -65.7512664794921875],  dtype=np.float64)
b_64 = np.array([61.221637725830078125, 71.60894012451171875, -65.72847747802734375], dtype=np.float64)

# create 32-bit versions of a and b
X = a_64.astype(np.float32)
Y = b_64.astype(np.float32)

X, Y = check_pairwise_arrays(X, Y)
XX = row_norms(X, squared=True)[:, np.newaxis]
YY = row_norms(Y, squared=True)[np.newaxis, :]

#Euclidean distance computed using product-then-sum
distances = safe_sparse_dot(X, Y.T, dense_output=True)
distances *= -2
distances += XX
distances += YY
print(np.sqrt(distances))

#Euclidean distance computed using (X-Y)^2
print(np.sqrt(row_norms(X-Y, squared=True)[:, np.newaxis]))

```

**OUTPUT**
```
[[ 0.03125]]
[[ 0.02290595136582851409912109375]]
```
The first method is how it is computed by the euclidean distance function. 
Also to clarify what I meant above was the fact that sum-then-product has lower precision even when we use numpy functions to do it

Yes, I can replicate this. I see that doing the subtraction initially
allows the precision of the difference to be maintained. Doing the dot
product and then subtracting (or negating and adding), as we currently do,
loses this precision as the most significant figures are much larger than
the differences.

The current implementation is more memory efficient for a high number of
features. But I suppose euclidean distance becomes increasingly irrelevant
in high dimensions, so the memory is dominated by the number of output
values.

So I vote for adopting the more numerically stable implementation over the
d-asymptotically efficient implementation we currently have. An opinion,
@ogrisel? @agramfort?

And this is of course more of a concern since we recently allowed float32s
to be more commonplace across estimators.

So for this example product-then-sum works perfectly fine for np.float64, so a possible solution could be to convert the input to float64 then compute the result and return the result converted back to float32. I guess this would be more efficient, but not sure if this would work fine for some other example.
converting to float64 won't be more efficient in memory usage than
subtraction.

Oh yeah you are right sorry about that, but I think using float64 and then doing product-then-sum would be more efficient computationally if not memory wise.
And the reason for using product-then-sum was to have more computational efficiency and not memory efficiency.
sure, but I don't believe there is any reason to assume that it is in fact
more computationally efficient except by way of not having to realise an
intermediate array. Assuming we limit absolute working memory (e.g. by
chunking), why would taking the dot product, doubling and subtracting norms
be much more efficient than subtracting and squaring?

Provide benchmarks?

Ok so I created a python script to compare the time taken by subtraction-then-squaring and conversion to float64 then product-then-sum and it turns out if we choose an X and Y as very big vectors then the 2 results are very different. Also @jnothman you were right subtraction-then-squaring is faster. 
Here's the script that I wrote, if there's any problem please let me know 

```
import numpy as np
import scipy
from sklearn.metrics.pairwise import check_pairwise_arrays, row_norms
from sklearn.utils.extmath import safe_sparse_dot
from timeit import default_timer as timer

for i in range(9):
	X = np.random.rand(1,3 * (10**i)).astype(np.float32)
	Y = np.random.rand(1,3 * (10**i)).astype(np.float32)

	X, Y = check_pairwise_arrays(X, Y)
	XX = row_norms(X, squared=True)[:, np.newaxis]
	YY = row_norms(Y, squared=True)[np.newaxis, :]

	#Euclidean distance computed using product-then-sum
	distances = safe_sparse_dot(X, Y.T, dense_output=True)
	distances *= -2
	distances += XX
	distances += YY

	ans1 = np.sqrt(distances)

	start = timer()
	ans2 = np.sqrt(row_norms(X-Y, squared=True)[:, np.newaxis])
	end = timer()
	if ans1 != ans2:
		print(end-start)

		start = timer()
		X = X.astype(np.float64)
		Y = Y.astype(np.float64)
		X, Y = check_pairwise_arrays(X, Y)
		XX = row_norms(X, squared=True)[:, np.newaxis]
		YY = row_norms(Y, squared=True)[np.newaxis, :]
		distances = safe_sparse_dot(X, Y.T, dense_output=True)
		distances *= -2
		distances += XX
		distances += YY
		distances = np.sqrt(distances)
		end = timer()
		print(end-start)
		print('')
		if abs(ans2 - distances) > 1e-3:
			# np.set_printoptions(precision=200)
			print(ans2)
			print(np.sqrt(distances))

			print(X, Y)
			break
```
it's worth testing how it scales with the number of samples, not just the
number of features... taking norms may have the benefit of computing some
things once per sample, not once per pair of samples

On 20 Oct 2017 2:39 am, "Osaid Rehman Nasir" <notifications@github.com>
wrote:

> Ok so I created a python script to compare the time taken by
> subtraction-then-squaring and conversion to float64 then product-then-sum
> and it turns out if we choose an X and Y as very big vectors then the 2
> results are very different. Also @jnothman <https://github.com/jnothman>
> you were right subtraction-then-squaring is faster.
> Here's the script that I wrote, if there's any problem please let me know
>
> import numpy as np
> import scipy
> from sklearn.metrics.pairwise import check_pairwise_arrays, row_norms
> from sklearn.utils.extmath import safe_sparse_dot
> from timeit import default_timer as timer
>
> for i in range(9):
> 	X = np.random.rand(1,3 * (10**i)).astype(np.float32)
> 	Y = np.random.rand(1,3 * (10**i)).astype(np.float32)
>
> 	X, Y = check_pairwise_arrays(X, Y)
> 	XX = row_norms(X, squared=True)[:, np.newaxis]
> 	YY = row_norms(Y, squared=True)[np.newaxis, :]
>
> 	#Euclidean distance computed using product-then-sum
> 	distances = safe_sparse_dot(X, Y.T, dense_output=True)
> 	distances *= -2
> 	distances += XX
> 	distances += YY
>
> 	ans1 = np.sqrt(distances)
>
> 	start = timer()
> 	ans2 = np.sqrt(row_norms(X-Y, squared=True)[:, np.newaxis])
> 	end = timer()
> 	if ans1 != ans2:
> 		print(end-start)
>
> 		start = timer()
> 		X = X.astype(np.float64)
> 		Y = Y.astype(np.float64)
> 		X, Y = check_pairwise_arrays(X, Y)
> 		XX = row_norms(X, squared=True)[:, np.newaxis]
> 		YY = row_norms(Y, squared=True)[np.newaxis, :]
> 		distances = safe_sparse_dot(X, Y.T, dense_output=True)
> 		distances *= -2
> 		distances += XX
> 		distances += YY
> 		distances = np.sqrt(distances)
> 		end = timer()
> 		print(end-start)
> 		print('')
> 		if abs(ans2 - distances) > 1e-3:
> 			# np.set_printoptions(precision=200)
> 			print(ans2)
> 			print(np.sqrt(distances))
>
> 			print(X, Y)
> 			break
>
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/9354#issuecomment-337948154>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz6z5o2Ao_7V5-Lflb4HosMrHCeOrVks5st209gaJpZM4OXbpZ>
> .
>

anyway, would you like to submit a PR, @ragnerok?
yeah sure, what do you want me to do ?
provide a more stable implementation, also a test that would fail under the
current implementation, and ideally a benchmark that shows we do not lose
much from the change, in reasonable cases.

I wanted to ask if it is possible to find distance between each pair of rows with vectorisation. I cannot think about how to do it vectorised.
You mean difference (not distance) between pairs of rows? Sure you can do that if you're working with numpy arrays. If you have arrays with shapes (n_samples1, n_features) and (n_samples2, n_features), you just need to reshape it to (n_samples1, 1, n_features) and (1, n_samples2, n_features) and do the subtraction:
```python
>>> X = np.random.randint(10, size=(10, 5))
>>> Y = np.random.randint(10, size=(11, 5))
X.reshape(-1, 1, X.shape[1]) - Y.reshape(1, -1, X.shape[1])
```
Yeah thanks that really helped 😄 
I also wanted to ask if I provide a more stable implementation I won't be using X_norm_squared and Y_norm_squared. So do I remove them from the arguments as well or should I warn about it not being of any use ?
I think they will be deprecated, but we might need to first be assured that
there's no case where we should keep that version.

we're going to be quite careful in changing this. it's a widely used and
longstanding implementation. we should be sure not to slow any important
cases. we might need to do the operation in chunks to avoid high memory
usage (which is perhaps made trickier by the fact that this is called
within functions that chunk to minimise the output memory retirement from
pairwise distances).

I'd really like to hear from other core devs who know about computational
costs and numerical precision... @ogrisel, @lesteve, @rth...

On 5 Nov 2017 5:27 am, "Osaid Rehman Nasir" <notifications@github.com>
wrote:

> I also wanted to ask if I provide a more stable implementation I won't be
> using X_norm_squared and Y_norm_squared. So do I remove them from the
> arguments as well or should I warn about it not being of any use ?
>
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/9354#issuecomment-341919282>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz63izdpQGDEuW32m8Aob6rrsvV6q-ks5szKyHgaJpZM4OXbpZ>
> .
>

but it would be easier to discuss precisely if you open a PR

Ok I'll open up a PR then, with a very basic implementation of this function
The questions is what should be done about this for the 0.20 release. Could there be some simple / temporary improvements (event at the cost e.g. of memory usage) that could be considered?

The solution and analysis proposed in #11271 are definitely very valuable, but it might require some more discussion to make sure this is the optimal solution. In particular, I am concerned about the fact that now we have some pending discussion about the optimal global working memory in  https://github.com/scikit-learn/scikit-learn/issues/11506 depending on the CPU type etc while this would add yet another level of chunking and the complexity of the whole would be getting a bit of control IMO. But maybe it's just me, looking for a second opinion.

What do you think should be done about this issue for the release @jnothman @amueller @ogrisel ?
Stability trumps efficiency. Stability issues should be fixed even when
efficiency still needs tweaks.

working_memory's focus was to make things like silhouette with large sample
sizes work. It also improved efficiency, but that can be tweaked down the
line.

I strongly believe we should try to get a fix for euclidean_distances with
float32 in. We broke it in 0.19 by assuming that we could make
euclidean_distances work on 32 bit in a naive way.

I agree that we need a fix. My concern here is not efficiency but the added complexity in the code base.

Taking a step back, scipy's euclidean implementation seems to be [10 lines of C code](https://github.com/scipy/scipy/blob/5e22b2e447cec5588fb42303a1ae796ab2bf852d/scipy/spatial/src/distance_impl.h#L49) and for 32 bit, simply cast them to 64bit. I understand that it's not the fastest but it's conceptually easy to follow and understand.  In scikit-learn, we use the trick to make computations faster in BLAS, then there are possible improvements due in https://github.com/scikit-learn/scikit-learn/pull/10212  and now the possible chunked solution to euclidean distance in 32 bit.

I'm just looking for input about what the general direction on this topic should be (e.g try to upstream some of it to scipy etc). 
scipy doesn't seem concerned by copying the data...

Move to 0.21 following the PR.
Remove the blocker?
`sqrt(dot(x, x) - 2 * dot(x, y) + dot(y, y))`

is numerically unstable, if dot(x,x) and dot(y,y) are of similar magnitude as dot(x,y) because of what is known as **catastrophic cancellation**.

This not only affect FP32 precision, but it is of course more prominent, and will fail much earlier.

Here is a simple test case that shows how bad this is even with double precision:
```
import numpy
from sklearn.metrics.pairwise import euclidean_distances

a = numpy.array([[100000001, 100000000]])
b = numpy.array([[100000000, 100000001]])

print "skelarn:", euclidean_distances(a, b)[0,0]
print "correct:", numpy.sqrt(numpy.sum((a-b)**2))

a = numpy.array([[10001, 10000]], numpy.float32)
b = numpy.array([[10000, 10001]], numpy.float32)

print "skelarn:", euclidean_distances(a, b)[0,0]
print "correct:", numpy.sqrt(numpy.sum((a-b)**2))
```
sklearn computes a distance of 0 here both times, rather than sqrt(2).

A discussion of the numerical issues for variance and covariance - and this trivially carries over to this approach of accelerating euclidean distance - can be found here:

> Erich Schubert, and Michael Gertz.
> **Numerically Stable Parallel Computation of (Co-)Variance.**
> In: Proceedings of the 30th International Conference on Scientific and Statistical Database Management (SSDBM), Bolzano-Bozen, Italy. 2018, 10:1–10:12

Actually the y coordinate can be removed from that test case, the correct distance then trivially becomes 1. I made a pull request that triggers this numeric problem:
```
    XA = np.array([[10000]], np.float32)
    XB = np.array([[10001]], np.float32)
    assert_equal(euclidean_distances(XA, XB)[0,0], 1)
```
I don't think my paper mentioned above provides a solution for this problem - just compute Euclidean distance as sqrt(sum(power())) and it is single-pass and has reasonable precision. The loss is in using the squares already, i.e., dot(x,x) itself already losing the precision.

@amueller as the problem may be more sever than expected, I suggest re-adding the blocker label...
Thanks for this very simple example.

The reason it is implemented this way is because it's way faster. See below:
```python
x = np.random.random_sample((1000, 1000))

%timeit euclidean_distances(x,x)
20.6 ms ± 452 µs per loop (mean ± std. dev. of 7 runs, 10 loops each)

%timeit cdist(x,x)
695 ms ± 4.06 ms per loop (mean ± std. dev. of 7 runs, 1 loop each)
```

Although the number of operations is of the same order in both methods (1.5x more in the second one), the speedup comes from the possibility to use well optimized BLAS libraries for matrix matrix multiplication.

This would be a huge slowdown for several estimators in scikit-learn.
Yes, but **just 3-4 digits of precision** with FP32, and 7-8 digits with FP64 *does* cause substantial imprecision, doesn't it? In particular, since such errors tend to amplify...
Well I'm not saying that it's fine right now. :)
I'm saying that we need to find a solution in between.
There is a PR (#11271) which proposes to cast on float64 to do the computations. In does not fix the problem for float64 but gives better precision for float32.

Do you have an example where using an estimator which uses euclidean_distances gives wrong results due to the loss of precision ?
I certainly still think this is a big deal and should be a blocker for 0.21. It was an issue introduced for 32 bit in 0.19, and it's not a nice state of affairs to leave. I wish we had resolved it earlier in 0.20, and I would be okay, or even keen, to see #11271 merged in the interim. The only issues in that PR that I know of surround optimisation of memory efficiency, which is a deep rabbit hole.

We've had this "fast" version for a long time, but always in float64. I know, @kno10, that it's got issues with precision. Do you have a good and fast heuristic for us to work out when that might be a problem and use a slower-but-surer solution?
> Yes, but just 3-4 digits of precision with FP32, and 7-8 digits with FP64 does cause substantial imprecision, doesn't it

Thanks for illustrating this issue with very simple example!

I don't think the issue is as widespread as you suggest, however -- it mostly affects samples whose mutual distance small with respect to their norms.

The below figure illustrates this, for 2e6 random sample pairs, where each 1D samples is in the interval [-100, 100]. The relative error between the scikit-learn and scipy implementation is plotted as a function of the distance between samples, normalized by their L2 norms, i.e.,
```
d_norm(A, B) = d(A, B) / sqrt(‖A‖₂*‖B‖₂)
```
(not sure it's the right parametrization, but just to get results somewhat invariant to the data scale),
![euclidean_distance_precision_1d](https://user-images.githubusercontent.com/630936/45919546-41ea1880-be97-11e8-9707-9279dfac4f5b.png)


For instance, 
  1. if one takes `[10000]` and `[10001]` the L2 normalized distance is 1e-4 and the relative error on the distance calculation will be 1e-8 in 64 bit, and >1 in 32 bit (Or 1e-8 and >1 in absolute value respectively). In 32 bit this case is indeed quite terrible.
  2. on the other hand for `[1]` and `[10001]`, the relative error will be ~1e-7 in 32 bit, or the maximum possible precision. 

The question is how often the case 1. will happen in practice in ML applications. 

Interestingly, if we go to 2D, again with a uniform random distribution, it will be difficult to find points that are very close,
![euclidean_distance_precision_2d](https://user-images.githubusercontent.com/630936/45919664-37308300-be99-11e8-8a01-5f936524aea5.png)

Of course, in reality our data will not be uniformly sampled, but for any distribution because of the curse of dimensionality the distance between any two points will slowly converge to very similar values (different from 0) as the dimentionality increases. While it's a general ML issue, here it may mitigate somewhat this accuracy problem, even for relatively low dimensionality. Below the results for `n_features=5`,
![euclidean_distance_precision_5d](https://user-images.githubusercontent.com/630936/45919716-3fd58900-be9a-11e8-9a5f-17c1a7c60102.png).

So for centered data, at least in 64 bit, it may not be so much of an issue in practice (assuming there are more then 2 features). The 50x computational speed-up (as illustrated above) may be worth it (in 64 bit). Of course one can always add 1e6 to some data normalized in [-1, 1] and say that the results are not accurate, but I would argue that the same applies to a number of numerical algorithms, and working with data expressed in the 6th significant digit is just looking for trouble.

(The code for the above figures can be found [here](https://github.com/rth/ipynb/blob/master/sklearn/euclidean_distance_accuracy.ipynb)).

Any fast approach using the dot(x,x)+dot(y,y)-2*dot(x,y) version will likely have the same issue for all I can tell, but you'd better ask some real expert on numerics for this. I believe you'll need to double the precision of the dot products to get to approx. the precision of the *input* data (and I'd assume that if a user provides float32 data, then they'll want float32 precision, with float64, they'll want float64 precision). You may be able to do this with some tricks (think of Kahan summation), but it will very likely cost you much more than you gained in the first place.

I can't tell how much overhead you get from converting float32 to float64 on the fly for using this approach. At least for float32, to my understanding, doing all the computations and storing the dot products as float64 should be fine.

IMHO, the performance gains (which are not exponential, just a constant factor) are not worth the loss in precision (which can bite you unexpectedly) and the proper way is to not use this problematic trick. It may, however, be well possible to further optimize code doing the "traditional" computation, for example to use AVX. Because sum( (x-y)**2 ) is all but difficult to implement in AVX.
At the minimum, I would suggest renaming the method to `approximate_euclidean_distances`, because of the sometimes low precision (which gets worse the closer two values are, which *may* be fine initially then begin to matter when converging to some optimum), so that users are aware of this issue.
@rth thanks for the illustrations. But what if you are trying to optimize, e.g., x towards some optimum. Most likely the optimum will not be at zero (if it would always be your data center, life would be great), and eventually the deltas you are computing for gradients etc. may have some very small differences.
Similarly, in clustering, clusters will not all have their centers close to zero, but in particular with many clusters, x ≈ center with a few digits is quite possible.
Overall however, I agree this issue needs fixing. In any case we need to document the precision issues of the current implementation as soon as possible.

In general though I don't think the this discussion should happen in scikit-learn. Euclidean distance is used in various fields of scientific computing and IMO scipy mailing list or issues is a better place to discuss it: that community has also more experience with such numerical precision issues. In fact what we have here is a fast but somewhat approximate algorithm. We may have to implement some fixes workarounds in the short term, but in the long term it would be good to know that this will be contributed there.

For 32 bit, https://github.com/scikit-learn/scikit-learn/pull/11271 may indeed be a solution, I'm just not so keen of multiple levels of chunking all through the library as that increases code complexity, and want to make sure there is no better way around it.
Thanks for your response @kno10! (My above comments doesn't take it into account yet) I'll respond a bit later.
Yes, convergence to some point outside of the origin may be an issue.

> IMHO, the performance gains (which are not exponential, just a constant factor) are not worth the loss in precision (which can bite you unexpectedly) and the proper way is to not use this problematic trick.

Well a >10x slow down for their calculation in 64 bit will have a very real effect on users.

> It may, however, be well possible to further optimize code doing the "traditional" computation, for example to use AVX. Because sum( (x-y)**2 ) is all but difficult to implement in AVX.

Tried a quick naive implementation with numba (which should use SSE),
```py
@numba.jit(nopython=True, fastmath=True)              
def pairwise_distance_naive(A, B):
    n_samples_a, n_features_a = A.shape
    n_samples_b, n_features_b = B.shape
    assert n_features_a == n_features_b
    distance = np.empty((n_samples_a, n_samples_b), dtype=A.dtype)
    for i in range(n_samples_a):
        for j in range(n_samples_b):
            psum = 0.0
            for k in range(n_features_a):
                psum += (A[i, k] - B[j, k])**2
            distance[i, j] = math.sqrt(psum)
    return distance
```
getting a similar speed to scipy `cdist` so far (but I'm not a numba expert), and also not sure about the effect of `fastmath`.

>  using the dot(x,x)+dot(y,y)-2*dot(x,y) version

Just for future reference, what we are currently doing is roughly the following (because there is a dimension that doesn't show in the above notation),
```py
def quadratic_pairwise_distance(A, B):
    A2 = np.einsum('ij,ij->i', A, A)
    B2 = np.einsum('ij,ij->i', B, B)
    return np.sqrt(A2[:, None] + B2[None, :] - 2*np.dot(A, B.T))
```
where both `einsum` and `dot` now use BLAS. I wonder, if aside from using BLAS, this also actually does the same number of mathematical operations as the first version above. 
>  I wonder, if aside from using BLAS, this also actually does the same number of mathematical operations as the first version above.

No. The ((x - y)**2.sum()) performs
*n_samples_x * n_samples_y * n_features * (1 substraction + 1 addition + 1 multiplication)*
 whereas the x.x + y.y -2x.y performs 
*n_samples_x * n_samples_y * n_features * (1 addition + 1 multiplication)*.
There is a 2/3 ratio for the number of operations between the 2 versions.
Following the above discussion,
 - Made a PR to optionally allow computing euclidean distances exactly https://github.com/scikit-learn/scikit-learn/pull/12136
 - Some WIP to see if we can detect and mitigate the problematic points in https://github.com/scikit-learn/scikit-learn/pull/12142

For 32 bit, we still need to merge https://github.com/scikit-learn/scikit-learn/pull/11271 in some form though IMO, the above PRs are somewhat orthogonal to it.
FYI: when fixing some issues in OPTICS, and refreshing the test to use reference results from ELKI, these fail with `metric="euclidean"` but succeed with `metric="minkowski"`. The numerical differences are large enough to cause a different processing order (just decreasing the threshold is not enough).

https://github.com/kno10/scikit-learn/blob/ab544709a392e4dc7b22e9fd60c4755baf3d3053/sklearn/cluster/tests/test_optics.py#L588
I'm really not caught up on this, but I'm surprised there's no existing solution. This seems to be a very common computation and it looks like we're reinventing the wheel. Has anyone tried reaching out to the wider scientific computing community?
Not yet, but I agree we should. The only thing I found about this in scipy was https://github.com/scipy/scipy/pull/2815 and linked issues.
I feel @jeremiedbb might have an idea?
Unfortunately not a satisfying one yet :(

We'd like to rely on a highly optimized library for this kind of computation, as we do for linear algebra with BLAS libraries such as OpenBLAS or MKL. But euclidean distance is not part of it. The dot trick is an attempt at doing that relying on BLAS level 3 matrix-matrix multiplication subroutine. But this is not precise and there is no way to make it more precise using the same method. We have to lower our expectancy either in term of speed or in term of precision.

I think in some situations, full precision is not mandatory and keeping the fast method is fine. This is when the distances are used for "find the closest" tasks. The precision issues in the fast method appear when the distances between points is small compared to their norm (in a ratio ~< 1e-4 for float 32 and ~< 1e-8 for float64). First for this situation to happen, the dataset needs to be quite dense. Then to have an ordering error, you need to have the two closest points within almost the same distance. Moreover, in that case, in a ML point of view, both would lead to almost equally good fits.

In the above situation, there is something we can do to lower the frequency of these wrong ordering (down to 0 ?). In the pairwise distance argmin situation. We can move the misordering to points which are not the closest. Essentially using the fact that one of the norm is not necessary to find the argmin, see [comment](https://github.com/scikit-learn/scikit-learn/pull/11950#issuecomment-429916562). It has 2 advantages. It's a more robust (up to now I haven't found a wrong ordering yet) and it is even faster because it avoids some computations.

One drawback, still in the same situation, if at the end we want the actual distances to the closest points, the distances computed with the above method can't be used. They are only partially computed and they are not precise anyway. We need to re-compute the distances from each point to it's closest point. But this is fast because for each point there is only one distance to compute.

I wonder what I described above covers all the use case of euclidean_distances in sklearn. But I suggest to do that wherever it can be applied. To do that we can add a new parameter to euclidean_distances to only compute the necessary part in order to chain it with argmin. Then use it in pairwise_distances_argmin and in pairwise_distances_argmin_min (re computing the actual min distances at the end in the latter).

When we can't do that, fall back to the slow yet precise one, or add a switch like in #12136.
We can try to optimize it a bit to lower the performance drop cause I agree that [this](https://github.com/scikit-learn/scikit-learn/pull/12136#issuecomment-439097748) does not seem optimal. I have a few ideas for that.

Another possibility to keep using BLAS is combining `axpy` with `nrm2` but this is far from optimal. Both are BLAS level 1 functions, and it involves a copy. This would only be faster in dimension > 100.
Ideally we'd like the euclidean distance to be included in BLAS...

Finally, there is another solution, consisting in upcasting. This is done in #11271 for float32. The advantage is that the speed is just half the current one and precision is kept. It does not solve the problem for float64 however. Maybe we can find a way to do a similar thing in cython for float64. I don't know exactly how but using 2 float64 numbers to kind of simulate a float128. I can give it a try to see if it's somewhat doable.
> Ideally we'd like the euclidean distance to be included in BLAS...

Is that something the libraries would consider? If OpenBLAS does it we would be in a pretty good situation already...

Also, what's the exact differences between us doing it and the BLAS doing it? Detecting the CPU capabilities and deciding which implementation to use, or something like that? Or just having compiled versions for more diverse architectures?
Or just more time/energy spend writing efficient implementations?
This is interesting: an alternative implementation of the fast unstable method but claiming to be much faster than sklearn:
https://github.com/droyed/eucl_dist
(doesn't solve this issue at all though lol)
This discussion seems related https://github.com/scipy/scipy/issues/5657
Here's what julia does: https://github.com/JuliaStats/Distances.jl/blob/master/README.md#precision-for-euclidean-and-sqeuclidean
It allows setting a precision threshold to force recalculation.
Answering my own question: OpenBLAS has what looks like hand-written assembly for each processor (not architecture!) and heutistics to choose kernels for different problem sizes. So I don't think it's an issue of getting it into openblas as much as finding someone to write/optimize all those kernels...
Thanks for the additional thoughts!

In a partial response,

> We'd like to rely on a highly optimized library for this kind of computation, as we do for linear algebra with BLAS libraries such as OpenBLAS or MKL.

Yeah, I also was hoping we could do more of this in BLAS. Last time I looked nothing in standard BLAS API looks close enough (but then I'm not an expert on those). [BLIS](https://github.com/flame/blis) might offer more flexibility but since we are not using it by default it's of somewhat limited use (though numpy might someday https://github.com/numpy/numpy/issues/7372) 

> Here's what julia does: It allows setting a precision threshold to force recalculation.

Great to know!


Should we open a separate issue for the faster approximate computation linked above? Seems interesting
Their speedup on CPU of x2-x4 might be due to https://github.com/scikit-learn/scikit-learn/pull/10212 .

I would rather open an issue on scipy once we have studied this question enough to come up with a reasonable solution there (and then possibly backport it) as I feel euclidean distance is something basic enough that should be of interest to many people outside of ML (and at the same time having the opinion of people there e.g. on accuracy issues would be helfpul).
It's up to 60x, right?
> This is interesting: an alternative implementation of the fast unstable method but claiming to be much faster than sklearn

hum not sure about that. They are benchmarking `%timeit pairwise_distances(a,b, 'sqeuclidean')`, which uses scipy's one. They should do `%timeit pairwise_distances(a,b, 'euclidean', metric_params={'squared': True})` and their speedup wouldn't be as good :)
As shown far earlier in the discussion, sklearn can be 35x faster than scipy
Yes, they benchmarks are only ~30% better better with `metric="euclidean"` (instead of `squeclidean`),

```py
In [1]: from eucl_dist.cpu_dist import dist                                                                                                                  
    ... import numpy as np                                                                                                                                   
In [4]: rng = np.random.RandomState(1)                                                                                                                        
    ... a = rng.rand(1000, 300)                                                                                                                              
    ...b = rng.rand(1000, 300)                                                                                                                              

In [7]: from sklearn.metrics.pairwise import pairwise_distances                                                                                              
In [8]: %timeit pairwise_distances(a, b, 'sqeuclidean')                                                                                                      
214 ms ± 2.06 ms per loop (mean ± std. dev. of 7 runs, 1 loop each)

In [9]: %timeit pairwise_distances(a, b)                                                                                                                     
27.4 ms ± 2.48 ms per loop (mean ± std. dev. of 7 runs, 10 loops each)

In [10]: from eucl_dist.cpu_dist import dist                                                                                                                 
In [11]: %timeit dist(a, b, matmul='gemm', method='ext', precision='float32')                                                                                
20.8 ms ± 330 µs per loop (mean ± std. dev. of 7 runs, 10 loops each)

In [12]: %timeit dist(a, b, matmul='gemm', method='ext', precision='float64')                                                                                
20.4 ms ± 222 µs per loop (mean ± std. dev. of 7 runs, 10 loops each)
```
> Is that something the libraries would consider? If OpenBLAS does it we would be in a pretty good situation already...

Doesn't sound straightforward. BLAS is a set of specs for linear algebra routines and there are several implementations of it. I don't know how open they are to adding new features not in the original specs. For that maybe blis would be more open but as said before, it's not the default for now.
Opened https://github.com/scikit-learn/scikit-learn/issues/12600 on the `sqeuclidean` vs `euclidean` handling in `pairwise_distances`.
I need some clarity about what we want for this. Do we want `pairwise_distances` to be close - in the sense of `all_close` - for both 'euclidean' and 'sqeuclidean' ?

It's a bit tricky. Because x is close to y does not mean x² is close to y². Precision is lost during squaring.

The julia workaround linked above is very interesting and is kind of straightforward to implement. However I suspect that it does not work as expected for 'sqeuclidean'. I suspect that you have to set the threshold way below to get the desired precision.

The issue with setting a very low threshold is that it induces a lot of re-computations and a huge drop of performances. However this is mitigated by the dimension of the dataset. The same threshold will trigger way less re-computations in high dimension (distances are bigger). 

Maybe we can have 2 implementations and switch depending on the dimension of the dataset. The slow but safe one for low dimensional ones (there not much difference between scipy and sklearn in that case anyway) and the fast + threshold one for high dimensional ones.

This will need some benchmarks to find when to switch, and set the threshold but this may be a glimmer of hope :)
Here are some benchmarks for speed comparison between scipy and sklearn. The benchmarks compare `sklearn.metrics.pairwise.euclidean_distances(X,X)` with `scipy.spatial.distance.cdist(X,X)` for Xs of all sizes. Number of samples goes from 2⁴ (16) to 2¹³ (8192), and number of features goes from 2⁰ (1) to 2¹³ (8192).

The value in each cell is the speedup of sklearn vs scipy, i.e. below 1 sklearn is slower and above 1 sklearn is faster.

The first benchmark is using the MKL implementation of BLAS and a single core.
![bench_euclidean_mkl_1](https://user-images.githubusercontent.com/34657725/48772816-c6092280-ecc5-11e8-94fe-68a7a5cdf304.png)

The second one is using the OpenBLAS implementation of BLAS and a single core. It's just to check that both MKL and OpenBLAS have the same behavior.
![bench_euclidean_openblas_1](https://user-images.githubusercontent.com/34657725/48772823-cacdd680-ecc5-11e8-95f7-0f9ca8baca9e.png)

The third one is using the MKL implementation of BLAS and 4 cores. The thing is that `euclidean_distances` is parallelized through a BLAS LEVEL 3 function but `cdist` only uses a BLAS LEVEL 1 function. Interestingly it almost doesn't change the frontier.
![bench_euclidean_mkl_4](https://user-images.githubusercontent.com/34657725/48774974-f18f0b80-eccb-11e8-925f-2a332891d957.png)


When n_samples is not too low (>100), it seems that the frontier is around 32 features. We could decide to use cdist when n_features < 32 and euclidean_distances when n_features > 32. This is faster and there no precision issue. This also has the advantage that when n_features is small, the julia threshold leads to a lot of re-computations. Using cdist avoids that.

When n_features > 32, we can keep the `euclidean_distances` implementation, updated with the julia threshold. Adding the threshold shouldn't slow `euclidean_distances` too much because the number of features is high enough so that only a few re-computations are necessary.



@jeremiedbb great, thank you for the analysis. The conclusion sounds like a great way forward to me.
Oh, I assume this was all for float64, right? What do we do with float32? upcast always? upcast for >32 features?
I've not read through the comments carefully (will soon), just FYI that float64 has it limitations, see #12128
@qinhanmin2014 yes, float64 precision has limitations, but it is precise enough for producing reliable fp32 results for all I can tell. The question is at which parameters an upcast to fp64 is actually cheaper than using cdist from scipy.
As seen in above benchmarks, even multi-core BLAS is *not* generally faster. This seems to mostly hold for high dimensional data (over 64 dimensions; before that the benefit is usually not worth the effort IMHO) - and since Euclidean distances are not that reliable in dense high dimensional data, that use case IMHO is not of highest importance. Many users will have less than 10 dimensions. In these cases, cdist seems to usually be faster?
> Oh, I assume this was all for float64, right?

Actually it's for both float32 and float64 (I mean very similar). I suggest to always use cdist when n_features < 32.

> The question is at which parameters an upcast to fp64 is actually cheaper than using cdist from scipy.

Upcasting will slowdown by a factor of ~2 so I guess around n_features=64.

> Many users will have less than 10 dimensions. 

But not everyone, so we still need to find a solution for high dimensional data.

Very nice analysis @jeremiedbb !

For low dimensional data it would definitely make sense to use cdist then.

Also, FYI scipy's cdist upcasts float32 to float64 https://github.com/scipy/scipy/issues/8771#issuecomment-384015674, I'm not sure if this is due to accuracy issues or something else. 

Overall, I think it could make sense to add the "algorithm" parameter to `euclidean_distance` as suggested in https://github.com/scikit-learn/scikit-learn/pull/12601#pullrequestreview-176076355, possibly with a default to "None" so that it could also be set via a  global option as in https://github.com/scikit-learn/scikit-learn/pull/12136.
There's also an interesting approach in Eigen3 to compute stable norms: https://eigen.tuxfamily.org/dox/StableNorm_8h_source.html (that I haven't really grokked yet)
Good Explanation, Improved my understanding
We haven't made any progress on this at the sprint and we probably should... and @rth is not around today.
I can join remotely if you set a time. Maybe in the beginning of afternoon?

To summarize the situation,

For precision issues in Euclidean distance calculations,
 - in the low dimensional case, as @jeremiedbb showed above, we should probably use cdist
 - in the high dimensional case and float32, we could choose between,
    - chunking, computing the distance in 64 bit and concatenating
    - falling back to cdist in cases when precision is an issue (how is an open question -- reaching out e.g. to scipy might be useful https://github.com/scikit-learn/scikit-learn/issues/9354#issuecomment-438522881 )

Then there are all the issues of inconsistencies between euclidean, sqeuclidean, minkowski, etc.
In terms of the precisions, @jeremiedbb, @amueller and I had a quick chat, mostly just milking Jeremie for his expertise. He is of the opinion that we don't need to worry so much about the instability issues in an ML context in high dimensions in float64. Jeremie also implied that it is hard to find an efficient test for whether good results have been returned (cf. #12142)

So I think we're happy with @rth's [preceding comment](https://github.com/scikit-learn/scikit-learn/issues/9354#issuecomment-468173901) with the upcasting for float32. Since cdist also upcasts to float64, we could reimplement cdist to take float32 (but with float64 accumulators?), or could use chunking, if we want less copying in low-dim float32.

Does @Celelibi want to change the PR in #11271, or should someone else (one of us?) produce a complete pull request?

And once this has been fixed, I think we should make sqeuclidean and minkowski(p in {0,1}) use our implementations. We've not discussed discrepancy with NearestNeighbors. Another sprint :)
After a quick discussion at the sprint we ended up on the following way:

- in high dimensional case (> 32 or > 64 choose the best): upcast by chunks to float64 when it's float32 and keep the 'fast' method. For this kind of data, numerical issues, on float64, are almost negligible (I'll provide benchmarks for that)

- in low dimensional case: implement the safe computation (instead of using scipy cdist because of the upcast) in sklearn.

(It's tempting to throw upcasting float32 into 0.20.3 also)
Ping when you feel it's ready for review!​

Thanks

@jnothman, Now that all tests pass, I think it's ready for review.
> This is certainly very precise, but perhaps not so elegant! I think it looks pretty good, but I'll have to look again later.

This is indeed not my proudest code. I'm open to any suggestion to refactor the code in addition to the small fix you suggested.

BTW, shall I make a new pull request with the changes in a new branch?
May I modify my branch and force push it?
Or maybe just add new commits to the current branch?

> Could you report some benchmarks here please?

Here you go.

### Optimal memory size
Here are the plots I used to choose the amount of 10MB of temporary memory. It measures the computation time with some various number of samples and features. Distinct X and Y are passed, no squared norm.
![multiplot_memsize](https://user-images.githubusercontent.com/6136274/41529630-0f92c430-72ee-11e8-9dad-c4c3f30498fa.png)
For 100 features, the optimal memory size seems to be about 5MB, but the computation time is quite short. While for 1000 features, it seems to be more between 10MB and 30MB. I thought about computing the optimal amount of memory from the shape of X and Y. But I'm not sure it's worth the added complexity.

Hm. after further investigation, it looks like optimal memory size is the one that produce a block size around 2048. So... maybe I could just add `bs = min(bs, 2048)` so that we get both a maximum of 10MB and a fast block size for small number of features?

### Norm squared precomputing
Here are some plots to see whether it's worth precomputing the norm squared of X and Y. The 3 plots on the left have a fixed number of samples (shown above the plots) and vary the number of features. The 3 plots on the right have a fixed number of features and vary the number of samples.
![multiplot_precompute_full](https://user-images.githubusercontent.com/6136274/41533633-c7a3da66-72fb-11e8-8d7f-159f87d3e4a9.png)
The reason why varying the number of features produce so much variations in the performance might be because it makes the block size vary too.

Let's zoom on the right part of the plots to see whether it's worth precomputing the squared norm.

![multiplot_precompute_zoom](https://user-images.githubusercontent.com/6136274/41533980-0b2499c8-72fd-11e8-9c63-e12ede299753.png)
For a small number of features and samples, it doesn't really matter. But if the number of samples or features is large, precomputing the squared norm of X does have a noticeable impact on the performance. On the other hand, precomputing the squared norm of Y doesn't change anything. It would indeed be computed anyway by the code for float64.

However, a possible improvement not implemented here could be to use some of the allowed additional memory to precompute and cache the norm squared of Y for some blocks (if not all). So that they could be reused during the next iteration over the blocks of X.

### Casting the given norm squared
When both `X_norm_squared` and `Y_norm_squared` are given, is it worth casting them to float64?
![multiplot_cast_zoom](https://user-images.githubusercontent.com/6136274/41535401-75be86f4-7302-11e8-8ce0-9457d0d6980e.png)
It seems pretty clear that it's always worth casting the squared norms when they are given. At least when the numbrer of samples is large enough. Otherwise it doesn't matter.

However, I'm not exactly sure why casting `Y_norm_squared` makes such a difference. It looks like the broadcasting+casting in `distances += YY` is suboptimal.

As before, a possible improvement not implemented could be to cache the casted blocks of the squared norm of `Y_norm_squared` so that they could be reused during the next iteration over the blocks of X.

### Swapping X and Y
Is it worth swapping X and Y when only `X_norm_squared` is given?
Let's plot the time taken when either `X_norm_squared` or `Y_norm_squared` is given and casted to float64, while the other is precomputed.
![multiplot_swap_zoom](https://user-images.githubusercontent.com/6136274/41536751-c4910104-7306-11e8-9c56-793e2f41a648.png)
I think it's pretty clear for a large number of features or samples that X and Y should be swapped when only `X_norm_squared` is given.

Is there any other benchmark you would want to see?

Overall, the gain provided by these optimizations is small, but real and consistent. It's up to you to decide whether it's worth the complexity of the code. ^^
> BTW, shall I make a new pull request with the changes in a new branch?
> May I modify my branch and force push it?
> Or maybe just add new commits to the current branch?

I had to rebase my branch and force push it anyway for the auto-merge to succeed and the tests to pass.

@jnothman wanna have a look at the benchmarks and discuss the mergability of those commits?
yes, this got forgotten, I'll admit.

but I may not find time over the next week. ping if necessary

@rth, you may be interested in this PR, btw.

IMO, we broke euclidean distances for float32 in 0.19 (thinking that
avoiding the upcast was a good idea), and should prioritise fixing it.

Very nice benchmarks and PR @Celelibi !

It would be useful to also test the net effect of this PR  on performance e.g. of KMeans / Birch as suggested in https://github.com/scikit-learn/scikit-learn/pull/10069#issuecomment-342347548 

I'm not yet  sure how this would interact with `pairwise_distances_chunked(.., metric="euclidean")` -- I'm wondering if could be possible to reuse some of that work, or at least make sure we don't chunk twice in this case. In any case it might make sense to use `with sklearn.config_context(working_memory=128):` context manager to defined the amount of memory per block.
> I'm not yet sure how this would interact with pairwise_distances_chunked(.., metric="euclidean")

I didn't forsee this. Well, they might chunk twice, which may have a bad impact on performance.

> I'm wondering if could be possible to reuse some of that work, or at least make sure we don't chunk twice in this case.

It wouldn't be easy to have the chunking done at only one place in the code. I mean the current code always use `Y` as a whole. Which means it should be casted entirely. Even if we fixed it to chunk both `X` and `Y`, the chunking code of `pairwise_distances_chunked` isn't really meant to be intermixed with some kind of preprocessing (nor should it IMO).

The best solution I could see right now would be to have some specialized chunked implementations for some metrics. Kind of the same way `pairwise_distance` only rely on `scipy.distance.{p,c}dist` when there isn't a better implementation.
What do you think about it?

BTW `pairwise_distances` might currently use `scipy.spatial.{c,p}dist`, which (in addition to being slow) handle float32 by casting first and returning a float64 result. This might be a problem with `sqeuclidean` metric which then behave differently from `euclidean` in that regard in addition to being a problem with the general support of float32.

> In any case it might make sense to use `with sklearn.config_context(working_memory=128):` context manager to defined the amount of memory per block.

Interesting, I didn't know about that. However, it looks like `utils.get_chunk_n_rows` is the only function to ever use that setting. Unfortunately I can't use that function since I have to _at least_ take into account the casted copy of `X` and the result chunk. But I could still use the amount of working memory that is set instead of a magic value.

> It would be useful to also test the net effect of this PR on performance e.g. of KMeans / Birch as suggested in #10069 (comment)

That comment was about deprecating `{X,Y}_norm_squared` and its impact on performance on the algorithms using it. But ok, why not. I haven't made a benchmark comparing the older code.
I think given that we seem to see that this operation works well with 10MB
working mem and the default working memory is 1GB, we should consider this
a negligible addition, and not use the working_memory business with it.​

I also think it's important to focus upon this as a bug fix, rather than
something that needs to be perfected in one shot.

@Celelibi Thanks for the detailed response!

> I think given that we seem to see that this operation works well with 10MB
working mem and the default working memory is 1GB we should consider this
a negligible addition, and not use the working_memory business with it.​


@jeremiedbb, @ogrisel mentioned that you run some benchmarks demonstrating that using a smaller working memory had higher performance on your system. Would you be able to share those results (the original benchmarks are in https://github.com/scikit-learn/scikit-learn/pull/10280#issuecomment-356419843)? Maybe in a separate issue. Thanks!
from my understanding this will take some more work. untagging 0.20.
Yes, it's pretty bad. Integrated these tests into https://github.com/scikit-learn/scikit-learn/pull/12142

Also (for other readers) most of the discussion about this is happening in https://github.com/scikit-learn/scikit-learn/issues/9354