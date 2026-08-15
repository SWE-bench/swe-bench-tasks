It could be stateful for KNN, right? That might not be totally useless. But not sure if that's something that people are doing.
But yeah, it's a strange feature, and I wouldn't be opposed to removing it.
I'm not sure what it means in a knn imputation context.

On 1 Aug 2017 2:22 am, "Andreas Mueller" <notifications@github.com> wrote:

> It could be stateful for KNN, right? That might not be totally useless.
> But not sure if that's something that people are doing.
> But yeah, it's a strange feature, and I wouldn't be opposed to removing it.
>
> —
> You are receiving this because you authored the thread.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/9463#issuecomment-319122664>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz65q63aHLWT8YCLqxQeiJLf0HV1Znks5sTf9DgaJpZM4OniQC>
> .
>

Well you could learn which feature is most common to which feature is most common to which other feature, and then impute using a distance weighted average of these features.
You could learn something like "this feature is always the average of these other two features" or "these features are perfectly correlated".
sounds like messy code to maintain, because behaviour with axis=1 is subtly
different: the axis=0 version of KNN gets the query from the test data and
the values to average from the training data; the axis=1 version gets the
query from the training data, i.e. nearest neighbors can be precomputed and
the values from the test data. I would rather see a KNNRowImputer if it's
well motivated.

On 2 Aug 2017 7:46 am, "Andreas Mueller" <notifications@github.com> wrote:

> Well you could learn which feature is most common to which feature is most
> common to which other feature, and then impute using a distance weighted
> average of these features.
> You could learn something like "this feature is always the average of
> these other two features" or "these features are perfectly correlated".
>
> —
> You are receiving this because you authored the thread.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/9463#issuecomment-319506442>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz62-RXpPsETqkB5GubxAV4uwFd5wJks5sT5yfgaJpZM4OniQC>
> .
>

yeah I agree.
Since the only other sensible value would be `axis=0`, then this means we should probably deprecate the parameter completely?
