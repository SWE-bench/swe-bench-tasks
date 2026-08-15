It doesn't seem like a well-defined problem in the case of a single input to me. I'm not sure what you'd expect to get
I'm skipping the computation if there are 0 relevant documents (any(truths) is False), since the metric is undefined.
For a single input, where truth = [1], I would expect to get 1 if prediction is 1, or 0 if predictions is 0 (according to the ndcg definition)
pinging @jeremiedbb and @jeromedockes who worked on the implementation.
> I would expect to get 1 if prediction is 1, or 0 if predictions is 0 (according to the ndcg definition)

which ndcg definition, could you point to a reference? (I ask because IIRC there is some variability in the definitions people use).

Normalized DCG is the ratio between the DCG obtained for the predicted and true rankings, and in my understanding when there is only one possible ranking (when there is only one candidate as in this example), both rankings are the same so this ratio should be 1. (this is the value we obtain if we disable [this check](https://github.com/scikit-learn/scikit-learn/blob/5aecf201a3d9ee8896566a057b3a576f1e31d410/sklearn/metrics/_ranking.py#L1347)).

however, ranking a list of length 1 is not meaningful, so if y_true has only one column it seems more likely that there was a mistake in the formatting/representation of the true gains, or that a user applied this ranking metric to a binary classification task. Therefore raising an error seems reasonable to me, but I guess the message could be improved (although it is hard to guess what was the mistake). showing a warning and returning 1.0 could also be an option
note this is a duplicate of #20119 AFAICT
HI jerome, you are right, I made a mistake. I'm using the definition on wikipedia
It looks like the results would be 0.0 if the document isn't a relevant one (relevance=0), or 1.0 if it is (relevance > 0). So the returned value could be equal to `y_true[0] > 0.` ?
In any case, I think that just updating error messages but keeping the current behaviour could be fine too
indeed when all documents are truly irrelevant and the ndcg is thus 0 / 0 (undefined) currently 0 is returned (as seen [here](https://github.com/scikit-learn/scikit-learn/blob/5aecf201a3d9ee8896566a057b3a576f1e31d410/sklearn/metrics/_ranking.py#L1516)).

but still I think measuring ndcg for a list of 1 document is not meaningful (regardless of the value of the relevance), so raising an error about the shape of y_true makes sense.
So we should improve the error message in this case.
I am happy to work on this if it hasn’t been assigned yet
@georged4s I can see that #24482 has been open but it seems stalled. I think that you can claim the issue and propose a fix. You can also look at the review done in the older PR.
Thanks @glemaitre for replying and for the heads up. Cool, I will look into this one.
I came here as I have suffered the same problem, it doesn't support binary targets.

Also, it would be great if it could be calculated simultaneously for a batch of users.
Hi, there doesn't seem to be a linked PR (excluding the stalled one), could I pick it up? 
Picking it up as part of the PyLadies "Contribute to scikit-learn" workshop
Hey there @mae5357, thank you for the contribution! Could you please:
1. Add some tests to confirm that the new error is properly raised?
2. Add a changelog entry describing the addition of the new error?

Regarding the code, I wonder if it would make sense just to include the check in `_check_dcg_traget_type` that way we don't need to introduce a new private function that could otherwise be easily inline.
I see a failed check on test coverege 
Hi @mae5357 Do you plan to continue working on this? If not, I'd like to continue.