The relevant issue on `libsvm` (i.e. issue https://github.com/cjlin1/libsvm/issues/85) seems to be stalled and I'm not sure if it's had a conclusion. At least on the `libsvm` side it seems they prefer not to include the confidences for computational cost of it.

Now the question is, do we want to change the `svm.cpp` to fix the issue and take the confidences into account? Or do we want the `SVC.predict` to use `SVC.decision_function` instead of calling `libsvm`'s `predict`? Or to fix the documentation and make it clear that `decision_function` and `predict` may not agree in case of a tie?
Does this related to #9174 also? Does #10440 happen to fix it??​

@jnothman not really, that's exactly the issue actually. the `predict` function which calls the `libsvm`'s `predict` function, does not use confidences to break the ties, but the `decision_function` does (as a result of the issue and the PR you mentioned).
Ah, I see.​ Hmm...

Another alternative is to have a `break_ties_in_predict` (or a much better parameter name that you can think of), have the default `False`, and if `True`, return the argmax of the decision_function. It would be very little code and backward compatible.
@adrinjalali and then change the default value? Or keep it inconsistent by default? (neither of these seems like great options to me ;)
@amueller I know it's not ideal, but my intuition says:

1- argmax of decision function is much slower than predict, which is why I'd see why in most usercases people would prefer to just ignore the tie breaking issue.
2- in practice, ties happen very rarely, therefore the inconsistency is actually not that big of an issue (we'd be seeing more reported issues if that was happening more often and people were noticing, I guess).

Therefore, I'd say the default value `False` is not an unreasonable case at all. On top of that, we'd document this properly both in the docstring and in the user manuals. And if the user really would like them to be consistent, they can make it so.

One could make the same argument and say the change is not necessary at all then. In response to which, I'd say the change is trivial and not much code at all, and easy to maintain, therefore there's not much damage the change would do. I kinda see this proposal as a compromise between the two cases of leaving it as is, and fixing it for everybody and breaking backward compatibility.

Also, independent of this change, if after the introduction of the change,we see some demand for the default to be `True` (which I'd doubt), we can do it in a rather long deprecation cycle to give people enough time to change/fix their code.

(I'm just explaining my proposed solution, absolutely no attachments to the proposal :P )
Adding a parameter would certainly make more users aware of this issue, and
it is somewhat like other parameters giving efficiency tradeoffs.

>
