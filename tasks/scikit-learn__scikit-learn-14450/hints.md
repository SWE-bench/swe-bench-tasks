What would you like to see instead? An assertion when the `fit` method is called that checks that no feature is constant, and returns a clear error if the assertion fails?
Already we raise an error. Better that we actually do the pls but disregard
the 0-variance column. See some of the comments at the original post.

As far as I understand we need to remove the warning message keeping the correct answer (when line yy[3,:] = [1,0,0,0,0] is uncommented ).
Can I try to solve this issue if nobody minds?
That's ok with me :)

On Wed, 17 Apr 2019, 00:46 iodapro, <notifications@github.com> wrote:

> As far as I understand we need to remove the warning message keeping the
> correct answer (when line yy[3,:] = [1,0,0,0,0] is uncommented ).
> Can I try to solve this issue if nobody minds?
>
> —
> You are receiving this because you commented.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/13609#issuecomment-483883450>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/Af8KsEcpWvUXFQhRVgyeBbVCyvCxEwpEks5vhmDBgaJpZM4cmyf4>
> .
>

> As far as I understand we need to remove the warning message keeping the correct answer

I'm not an expert on PLS; I was relying on the comments historically related to this issue to describe it as a simple fix. But certainly the problem is constant features.

Go ahead and submit a pull request, @iodapro 
@jnothman there is something I can't undestand about the example you give in the issue:  Even when we are uncommenting the line yy[3,:] = [1,0,0,0,0],  the third column of yy is constant, but in that case pls2.fit(xx, yy) works. Do we need two columns to be constant for the PLS to fail?
After taking a deeper look at the problem, the problem is not constant features. The problem is that the first column of the target (yy) is constant. For instance, this case will work (constant features and some constant columns in the target that are not the first column):
```
import numpy as np
import sklearn.cross_decomposition

pls2 = sklearn.cross_decomposition.PLSRegression()
xx = np.random.random((5,5))
xx[:,1] = 1
xx[:,2] = 0
yy = np.random.random((5,5))
yy[:,2] = 5
yy[:,4] = 1
pls2.fit(xx, yy)
pls2.predict(xx)
```

But this case won't (the first column in the target is a constant):
```
import numpy as np
import sklearn.cross_decomposition

pls2 = sklearn.cross_decomposition.PLSRegression()
xx = np.random.random((5,5))
yy = np.random.random((5,5))
yy[:,0] = 4
pls2.fit(xx, yy)
pls2.predict(xx)
```

This is because the first step of the `_nipals_twoblocks_inner_loop` algorithm is to calculate `y_score = Y[:, [0]]`  and this will cause the `x_weights = np.dot(X.T, y_score) / np.dot(y_score.T, y_score)` to be an array of nan.  This happens because `_center_scale_xy` will cause  the first column of yy to be a column of zeros.


