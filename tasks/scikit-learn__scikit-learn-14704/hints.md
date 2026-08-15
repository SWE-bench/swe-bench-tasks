I think there have been several issues about this.

I think we should go back to a sort-then-round-robin approach.

this behaviour is actually well-documented, see https://scikit-learn.org/dev/modules/generated/sklearn.model_selection.StratifiedKFold.html:
Train and test sizes may be different in each fold, with a difference of at most n_classes.
related issues: #10274 #2372
I agree that we might want a better StratifiedKFold
@jnothman could you provide more details about your solution?
You said in #10274:
The critique in #2372 was that the sampling did not maintain order of samples within each class, but I contend that could have been achieved with a stable sort rather than default sort.
But seems that the critique in #2372 is to preserve the dataset dependency, so stable sort won't solve the problem.
Ohhhh... Maybe I misunderstood all along. Hmm. Yuck. But determining the
number of test samples in each class by the equivalent of round robin
should solve the problem, shouldn't it??
