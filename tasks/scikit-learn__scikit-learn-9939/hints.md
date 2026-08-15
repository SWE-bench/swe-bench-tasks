Yes, just taking the coef for one class indeed seems incorrect. Is there
any way to adjust the coef of one class (and the intercept) given the other
to get the right probabilities?

> This is essentially a difference between softmax (redundancy allowed) and logistic regression.

Indeed, there is a difference in the way we want to compute `predict_proba`:
1. In OVR-LR, you want a sigmoid: `exp(D(x)) / (exp(D(x)) + 1)`, where `D(x)` is the decision function.
2. In multinomial-LR with `n_classes=2`, you want a softmax `exp(D(x)) / (exp(D(x)) + exp(-D(x))`.

So we **do** expect different results between (1) and (2). 
However, there is indeed a bug and your fix is correct:

In the current code, we incorrectly use the sigmoid on case (2). Removing lines 762 and 763 does solve this problem, but change the API of `self.coef_`, which specifically states `coef_ is of shape (1, n_features) when the given problem is binary`.

Another way to fix it is to change directly `predict_proba`, adding the case binary+multinomial:
```py
        if self.multi_class == "ovr":
            return super(LogisticRegression, self)._predict_proba_lr(X)
        elif self.coef_.shape[0] == 1:
            decision = self.decision_function(X)
            return softmax(np.c_[-decision, decision], copy=False)
        else:
            return softmax(self.decision_function(X), copy=False)
```
It will also break current behavior of `predict_proba`, but we don't need deprecation if we consider it is a bug.


If it didn't cause too many further issues, I think the first solution would be better i.e. changing the API of `self.coef_` for the `multinomial` case. This is because, say we fit a logistic regression `lr`, then upon inspecting the `lr.coef_ ` and `lr.intercept_` objects, it is clear what model is being used. 

I also believe anyone using `multinomial` for a binary case (as I was) is doing it as part of some more general functionality and will also be fitting non-binary models depending on their data. If they want to access the parameters of the models (as I was) `.intercept_` and `.coef_` their generalisation will be broken in the binary case if only `predict_proba` is changed.
We already break the generalisation elsewhere, as in `decision_function` and in the `coef_` shape for other multiclass methods. I think maintaining internal consistency here might be more important than some abstract concern that "generalisation will be broken". I think we should choose modifying `predict_proba`. This also makes it clear that the multinomial case does not suddenly introduce more free parameters.
I agree it would make more sense to have `coef_.shape = (n_classes, n_features)` even when `n_classes = 2`, to have more consistency and avoid special cases.

However, it is a valid argument also for the OVR case (actually, it is nice to have the same `coef_` API for both multinomial and OVR cases). Does that mean we should change the `coef_`  API in all cases? It is an important API change which will break a lot of user code, and which might not be consistent with the rest of scikit-learn...
Another option could be to always use the `ovr` method in the binary case even when `multiclass` is set to `multinomial`. This would avoid the case of models having exactly the same coefficients but predicting different values due to have different `multiclass` parameters. As previously mentioned, if `predict_proba` gets changed, the `multinomial` prediction would be particularly confusing if someone just looks at the 1D coefficients `coef_` (I think the `ovr` case is the intuitive one).

I believe by doing this, the only code that would get broken would be anyone who already knew about the bug and had coded their own workaround.

Note: If we do this, it is not returning the actual correct parameters with regards to the regularisation, despite the fact the solutions will be identical in terms of prediction. This may make it a no go.
Changing the binary coef_ in the general case is just not going to happen.
If you want to fix a bug, fix a bug...

On 10 October 2017 at 00:05, Tom Dupré la Tour <notifications@github.com>
wrote:

> I agree it would make more sense to have coef_.shape = (n_classes,
> n_features) even when n_classes = 2, to have more consistency and avoid
> special cases.
>
> However, it is a valid argument also for the OVR case (actually, it is
> nice to have the same coef_ API for both multinomial and OVR cases). Does
> that mean we should change the coef_ API in all cases? It is an important
> API changes which will break a lot of user code, and which might not be
> consistent with the rest of scikit-learn.
>
> —
> You are receiving this because you commented.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/9889#issuecomment-335150971>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz6-kpIPulfN1z6KQYbqEQP2bRd3pPks5sqhkPgaJpZM4PyMNd>
> .
>

Are the learnt probabilities then equivalent if it changes to ovr for 2
classes? Seems a reasonable idea to me.

Thinking about it, it works with no regularisation but when regularisation is involved we should expect slightly different results for `ovr` and `multinomial`.

Maybe then just change `predict_proba` as suggested and a warning message when fitting a binary model with `multinomial`.
why the warning? what would it say?

The issue is that the values of `coef_` do not intuitively describe the model in the binary case using `multinomial`. If someone fits a binary logistic regression and receives back a 1D vector of coefficients (`W` say for convenience), I would assume that they will think the predicted probability of a new observation `X`, is given by

    exp(dot(W,X)) / (1 + exp(dot(W,X)))

This is true in the `ovr` case only. In the `multinomial` case, it is actually given by

    exp(dot(W,X)) / (exp(dot(-W,X)) + exp(dot(W,X)))

I believe this would surprise and cause errors for many people upon receiving a 1D vector of coefficients `W` so I think they should be warned about it. In fact I wouldn't be surprised if people currently using the logistic regression coefficients in the `multinomial`, binary outcome case, have bugs in their code.

I would suggest a warning message when `.fit` is called with `multinomial`, when binary outcomes are detected. Something along the lines of (this can probably be made more concise):

    Fitting a binary model with multi_class=multinomial. The returned `coef_` and `intercept_` values form the coefficients for outcome 1 (True), use `-coef_` and `-intercept` to form the coefficients for outcome 0 (False).
I think it would be excessive noise to warn such upon fit. why not just
amend the coef_ description? most users will not be manually making
probabilistic interpretations of coef_ in any case, and we can't in general
stop users misinterpreting things on the basis of assumption rather than
reading the docs...

Fair enough. My only argument to the contrary would be that using `multinomial` for binary classification is a fairly uncommon thing to do, so the warning would be infrequent.

However I agree in this case that if a user is only receiving a 1D vector of coefficients (i.e. it is not in the general form as for dimensions > 2), then they should be checking the documentation for exactly what this means, so amending the `coef_` description should suffice.
So to sum-up, we need to:
 - update `predict_proba` as described in https://github.com/scikit-learn/scikit-learn/issues/9889#issuecomment-335129554
- update `coef_`'s docstring
- add a test and a bugfix entry in `whats_new`

Do you want to do it @rwolst ?
Sure, I'll do it.
Thanks