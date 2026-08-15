(Not an AdaBoost expert)

Why is it wrong? How else would you define `predict_proba`?

The idea of using only predictions during training and use afterwards probas of base_estimators is strange. The base_estimator can return -0.1 and 0.9 or -0.9 and 0.1.

They will have same predictions and different probas - but you don't take it into account.

The 'standart' scheme as I understand is:
There is score:

score(obj)  = sum[ weight_i \* esimator_i.predict(obj) ],
assuming that predict returns 1 and -1

Then this score is turned to proba by some sigmoid function (score_to_proba in sklearn's gradientBoosting)

> The base_estimator can return -0.1 and 0.9 or -0.9 and 0.1.

Not from `predict`, that returns discrete labels. But it is a bit strange that `predict_proba` should be needed on the base estimator if it's not used in training... @ndawe?

For sure not from predict, sorry. I wanted to say, the predict_proba 
can be [0.1, 0.9] or [0.6, 0.4] of one estimator and
[0.9, 0.1] or [0.4, 0.6] of another, but their predicts will be similar.

This estimators will be considered as similar during training, but at this moment they will have totally different influence on result of predict_proba of AdaBoost

In fact, I don't think `predict_proba` should even be defined when AdaBoost is built from the SAMME variant (which is a discrete boosting algorithm, for base estimators that only support crisp predictions). If I remember correctly, we added that for convenience only. 

What do you think @ndawe?

SAMME.R uses the class probabilities in the training but SAMME does not. That is how those algorithms are designed.

I agree that in the SAMME case, `predict_proba` could be a little ambiguous. Yes, you could transform the discrete labels into some form of probability as you suggest, but the current implementation uses the underlying `predict_proba` of the base estimator. I don't think this is strange but I'm open to suggestions. If the base estimator supports class probabilities, then SAMME.R is the better algorithm (generally). I suppose what we want here is some way of extracting "probabilities" from a boosted model that can only deliver discrete labels.

> I suppose what we want here is some way of extracting "probabilities" from a boosted model that can only deliver discrete labels.

Right. I was working on implementation of uBoost, some variation of AdaBoost, and this was the issue - the predictions of probabilities on some stage are used there to define weights on next iterations.

Somehow that resulted in poor uniformity of predictions. Fixing the `predict_proba` resolved this issue

The change I propose in predict_proba is (if `predict` of estimator returns only 0, 1!)

<pre>
 score = sum((2*estimator.predict(X) - 1) * w
       for estimator, w in zip(self.estimators_,  self.estimator_weights_))
 proba = sigmoid(score)
</pre>

where sigmoid is some sigmoid function.
