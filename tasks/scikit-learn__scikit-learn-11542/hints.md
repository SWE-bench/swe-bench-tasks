I would like to give it a shot. Is the default value 100 final? 
@ArihantJain456 I didn't tag this one as "help wanted" because I wanted to wait for other core devs to chime in before we do anything.
I agree. Bad defaults should be deprecated. The warning doesn't hurt.​

I'm also +1 for n_estimators=100 by default
Both for this and #11129 I would suggest that the deprecation warning includes a message to encourage the user to change the value manually.
Has someone taken this up? Can I jump on it?
Bagging* also have n_estimators=10. Is this also a bad default?
@jnothman I would think so, but I have less experience and it depends on the base estimator, I think? With trees, probably?
I am fine with changing the default to 100 for random forests and bagging. (with the usual FutureWarning cycle).

@jnothman I would rather reserve the Blocker label for things that are really harmful if not fixed. To me, fixing this issue is an easy nice-to-heave but does not justify delaying the release cycle.
Okay. But given the rate at which we release, I think it's worth making
sure that simple deprecations make it into the release.​ It's not a big
enough feature to *not* delay the release for it.

I agree.
I am currently working on this issue.