can u share me the refernce of the code where the bug was there
@TomDLT I'd be interested in you opinion. We hit this in https://github.com/scikit-learn/scikit-learn/pull/24365#discussion_r976815764.
I feel like computing a log loss with probabilities not summing to one does not make sense, so I am ok with the renormalization.

> a really bad model, the predictions of which do not sum to 1

To me this is not a bad model (a model that has poor prediction accuracy), this is an incorrect model (a model that does not return results in the expected format), as would be a model that predicts negative probabilities. We could almost raise an error if the probabilities do not sum to one (or close), but I feel like it is simpler to just renormalize and compute the loss.
> I feel like computing a log loss with probabilities not summing to one does not make sense, so I am ok with the renormalization.

To be honest, I strongly think renormalizing in the metric is methodologically wrong because this way the metric is not measuring the model prediction anymore. The model should take care of it's own predictions (i.e. make them sum to 1), not the metric!

A metric is like a measuring device, say a scale (for measuring weight). We are measuring objects for a flight transport, so lighter is better. Renormalization is like measuring the weight of objects with their packaging removed. But the flight will have to carry the whole objects, with packaging included.
> We could almost raise an error if the probabilities do not sum to one (or close), but I feel like it is simpler to just renormalize and compute the loss.

I would be fine with raising a warning first and an error in the future.
I agree with @lorentzenchr that the current behavior is very surprising and therefore it's a bug to me.
What should be the behavior for larger `eps` values? For example, the following has `eps=0.1`:

```python
from sklearn.metrics import log_loss
import numpy as np

y_true = [0, 1, 2]
y_pred = [[0, 0, 1], [0, 1, 0], [0, 0, 1]]

eps = 0.1
log_loss(y_true, y_pred, eps=eps)
# 0.9330788879075577

# `log_loss` will use a clipped `y_pred` for computing the log loss:
np.clip(y_pred, eps, 1 - eps)
# array([[0.1, 0.1, 0.9],
#        [0.1, 0.9, 0.1],
#        [0.1, 0.1, 0.9]])
```

We could just validate the input, i.e. `np.isclose(y_pred.sum(axis=1), 1.0)`, but `log_loss` will use the clipped version for computation. For reference, here is the clipping:

https://github.com/scikit-learn/scikit-learn/blob/d52e946fa4fca4282b0065ddcb0dd5d268c956e7/sklearn/metrics/_classification.py#L2629-L2630

For me, I think that `eps` shouldn't be a parameter and should always be `np.finfo(y_pred.dtype).eps`. For reference, PyTorch's `binary_cross_entropy` [clips the log to -100 by default](https://github.com/pytorch/pytorch/blob/e47af44eb81b9cd0c3583de91b0a2d4f56a5cf8d/aten/src/ATen/native/Loss.cpp#L292-L297)
I agree with @thomasjpfan that `eps` should not be a parameter. In my opinion, the perfect default value is 0 (what is the use case of having it in the first place?). I'm also fine with `np.finfo(y_pred.dtype).eps`.
@lorentzenchr Would it be okay for me to work on this issue?
@OmarManzoor If the solution is clear to you, then yes.
> @OmarManzoor If the solution is clear to you, then yes.

From what I can understand we need to raise a warning if `y_pred` does not sum to 1 and we need to remove eps as a parameter to this metric and instead use a value of `np.finfo(y_pred.dtype).eps`.
@OmarManzoor Yes. You are very welcome to go ahead, open a PR and link it with this issue. Keep in mind that `eps` needs a a deprecation cycle, i.e. throw a warning when set for 2 releases. Be prepared that a few concerns might be raised during review. 
> @OmarManzoor Yes. You are very welcome to go ahead, open a PR and link it with this issue. Keep in mind that `eps` needs a a deprecation cycle, i.e. throw a warning when set for 2 releases. Be prepared that a few concerns might be raised during review.

Sure thank you.