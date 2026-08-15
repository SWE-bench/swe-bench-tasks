As the square root is a monotonic function on the positive domain, taking the square root would have no effect on any model selection. Could you please mention a use-case when it taking the root has some real advantage?
> As the square root is a monotonic function on the positive domain, taking the square root would have no effect on any model selection

This is why we reject it previously I think (though I'm unable to find relevant discussions)
I'd argue that given the popularity of RMSE, it might be worthwhile to add several lines of (redundant) code for it (we only need <5 lines of code for the metric I think)
Sometimes users might want to report the RMSE of their model instead of MSE, because RMSE is more meaningful (i.e., it reflects the deviation between actual value and predicted value).

Hi,
If there is a consensus on this I would like to give this a try.
> If there is a consensus on this I would like to give this a try.

not yet, please wait or try another issue.
Hmm, I found https://github.com/scikit-learn/scikit-learn/pull/6457#issuecomment-253975180
I would like to work on this.