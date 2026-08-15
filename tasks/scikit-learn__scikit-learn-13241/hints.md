Looks like this sign flip thing was already noticed as part of https://github.com/scikit-learn/scikit-learn/issues/5970.

Using `sklearn.utils.svd_flip` may be the fix to have a deterministic sign.

Can you provide a stand-alone snippet to reproduce the problem ? Please read https://stackoverflow.com/help/mcve. Stand-alone means I can copy and paste it in an IPython session. In your case you have not defined `X` for example.

Also Readability counts, a lot! Please use triple back-quotes aka [fenced code blocks](https://help.github.com/articles/creating-and-highlighting-code-blocks/) to format error messages code snippets. Bonus points if you use [syntax highlighting](https://help.github.com/articles/creating-and-highlighting-code-blocks/#syntax-highlighting) with `py` for python snippets and `pytb` for tracebacks.
Hi there,

Thanks for your reply! The code file is attached.

[test.txt](https://github.com/scikit-learn/scikit-learn/files/963545/test.txt)

I am afraid that the data part is too big, but small training data cannot give the phenomenon. 
You can directly scroll down to the bottom of the code.
By the way, how sklearn.utils.svd_flip is used? Would you please give me some example by modifying
the code?

The result shows that
```python
# 1st run
[[-0.16466689  0.28032182  0.21064738 -0.12904448 -0.10446288  0.12841524
  -0.05226416]
 [-0.16467236  0.28033373  0.21066657 -0.12906051 -0.10448316  0.12844286
  -0.05227781]
 [-0.16461369  0.28020562  0.21045685 -0.12888338 -0.10425372  0.12812801
  -0.05211955]
 [-0.16455855  0.28008524  0.21025987 -0.12871706 -0.1040384   0.12783259
  -0.05197112]
 [-0.16448037  0.27991459  0.20998079 -0.12848151 -0.10373377  0.12741476
  -0.05176132]
 [-0.15890147  0.2676744   0.18938366 -0.11071689 -0.07950844  0.09357383
  -0.03398456]
 [-0.16447559  0.27990414  0.20996368 -0.12846706 -0.10371504  0.12738904
  -0.05174839]
 [-0.16452601  0.2800142   0.21014363 -0.12861891 -0.10391136  0.12765828
  -0.05188354]
 [-0.16462521  0.28023075  0.21049772 -0.12891774 -0.10429779  0.12818829
  -0.05214964]
 [-0.16471191  0.28042     0.21080727 -0.12917904 -0.10463582  0.12865199
  -0.05238251]]

# 2nd run
[[-0.16466689  0.28032182  0.21064738  0.12904448 -0.10446288  0.12841524
   0.05226416]
 [-0.16467236  0.28033373  0.21066657  0.12906051 -0.10448316  0.12844286
   0.05227781]
 [-0.16461369  0.28020562  0.21045685  0.12888338 -0.10425372  0.12812801
   0.05211955]
 [-0.16455855  0.28008524  0.21025987  0.12871706 -0.1040384   0.12783259
   0.05197112]
 [-0.16448037  0.27991459  0.20998079  0.12848151 -0.10373377  0.12741476
   0.05176132]
 [-0.15890147  0.2676744   0.18938366  0.11071689 -0.07950844  0.09357383
   0.03398456]
 [-0.16447559  0.27990414  0.20996368  0.12846706 -0.10371504  0.12738904
   0.05174839]
 [-0.16452601  0.2800142   0.21014363  0.12861891 -0.10391136  0.12765828
   0.05188354]
 [-0.16462521  0.28023075  0.21049772  0.12891774 -0.10429779  0.12818829
   0.05214964]
 [-0.16471191  0.28042     0.21080727  0.12917904 -0.10463582  0.12865199
   0.05238251]]
```
in which the sign flips can be easily seen.
Thanks for your stand-alone snippet, for next time remember that such a snippet is key to get good feedback.

Here is a simplified version showing the problem. This seems to happen only with the `arpack` eigen_solver when `random_state` is not set:

```py
import numpy as np
from sklearn.decomposition import KernelPCA

data = np.arange(12).reshape(4, 3)

for i in range(10):
    kpca = KernelPCA(n_components=2, eigen_solver='arpack')
    print(kpca.fit_transform(data)[0])
```

Output:
```
[ -7.79422863e+00   1.96272928e-08]
[ -7.79422863e+00  -8.02208951e-08]
[ -7.79422863e+00   2.05892318e-08]
[  7.79422863e+00   4.33789564e-08]
[  7.79422863e+00  -1.35754077e-08]
[ -7.79422863e+00   1.15692773e-08]
[ -7.79422863e+00  -2.31849470e-08]
[ -7.79422863e+00   2.56004915e-10]
[  7.79422863e+00   2.64278471e-08]
[  7.79422863e+00   4.06180096e-08]
```
Thanks very much!
I will check it later.
@shuuchen not sure why you closed this but I reopened this. I think this is a valid issue.
@lesteve OK.
@lesteve I was taking a look at this issue and it seems to me that not passing `random_state` cannot possibly yield the same result in different calls, given that it'll be based in a random uniformly distributed initial state. Is it really an issue?
I do not reproduce the issue when fixing the `random_state`:

```
In [6]: import numpy as np
   ...: from sklearn.decomposition import KernelPCA
   ...: 
   ...: data = np.arange(12).reshape(4, 3)
   ...: 
   ...: for i in range(10):
   ...:     kpca = KernelPCA(n_components=2, eigen_solver='arpack', random_state=0)
   ...:     print(kpca.fit_transform(data)[0])
   ...:     
[ -7.79422863e+00   6.27870418e-09]
[ -7.79422863e+00   6.27870418e-09]
[ -7.79422863e+00   6.27870418e-09]
[ -7.79422863e+00   6.27870418e-09]
[ -7.79422863e+00   6.27870418e-09]
[ -7.79422863e+00   6.27870418e-09]
[ -7.79422863e+00   6.27870418e-09]
[ -7.79422863e+00   6.27870418e-09]
[ -7.79422863e+00   6.27870418e-09]
[ -7.79422863e+00   6.27870418e-09]
```
@shuuchen can you confirm setting the random state solves the problem?

Also: did someone in Paris manage to script @lesteve? 
> I do not reproduce the issue when fixing the random_state:

This is what I said in https://github.com/scikit-learn/scikit-learn/issues/8798#issuecomment-297959575.

I still think we should avoid such a big difference using `svd_flip`. PCA does not have this problem because it is using `svd_flip` I think:

```py
import numpy as np
from sklearn.decomposition import PCA

data = np.arange(12).reshape(4, 3)

for i in range(10):
    pca = PCA(n_components=2, svd_solver='arpack')
    print(pca.fit_transform(data)[0])
```

Output:
```
[-0.          7.79422863]
[-0.          7.79422863]
[ 0.          7.79422863]
[ 0.          7.79422863]
[ 0.          7.79422863]
[-0.          7.79422863]
[ 0.          7.79422863]
[-0.          7.79422863]
[ 0.          7.79422863]
[-0.          7.79422863]
```

> Also: did someone in Paris manage to script @lesteve?

I assume you are talking about the relabelling of "Need Contributor" to "help wanted". I did it the hard way with ghi (command-line interface to github) instead of just renaming the label via the github web interface :-S.
I can do this to warm myself up for the sprint