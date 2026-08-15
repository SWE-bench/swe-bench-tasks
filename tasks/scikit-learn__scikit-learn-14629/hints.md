Please provide the full traceback to make it easier for us to see where the
error is raised. I will admit I'm surprised this still has issues, but it
is a surprisingly complicated bit of code.

I think this bug is in MultiOutputClassifier. All classifiers should store `classes_` when fitted.
Help wanted to add `classes_` to `MultiOutputClassifier` like it is in `ClassifierChain`