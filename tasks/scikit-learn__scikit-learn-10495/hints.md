ping @jnothman 

> This seems overly lenient and strange behaviour, as in #9342 where @qinhanmin2014 shows that check_array(['a', 'b', 'c'], dtype='numeric') works without error and produces an array of strings!

I think you mean #9835 (https://github.com/scikit-learn/scikit-learn/pull/9835#issuecomment-348069380) ?

Yes, from my perspective, if it is not intended, it seems a bug.
it seems memorising four digit numbers is not my speciality

Five now!
And I'm not entirely sure what my intended behavior was, but I agree with your assessment. This should error on strings.
I think, @amueller, for the next little while, the mere knowledge that a
number has five digits leaves the first with distinctly low entropy

Well, I guess it's one more bit, though ;)
@jnothman I'd be happy to give this a go with some limited guidance if no one else is working on it already. Looks like the behavior you noted comes from [this line](https://github.com/scikit-learn/scikit-learn/blob/202b5321f1798c4980abf69ac8c0a0969f01a2ec/sklearn/utils/validation.py#L480), where we're checking the array against the numpy object type when we'd like to check it against string and unicode types as well -- the `[['a', 'b', 'c']]` list in your example appears to be cast to the numpy unicode array type in your example by the time it reaches that line. Sound right?
I'd also be curious to hear what you had in mind in terms of longer term solution, i.e., what would replace `check_array` if deprecated?
> Perhaps we need a deprecation cycle
Something like that. Basically if dtype_numeric and array.dtype is not an
object dtype or a numeric dtype, we should raise.

On 17 January 2018 at 13:17, Ryan <notifications@github.com> wrote:

> @jnothman <https://github.com/jnothman> I'd be happy to give this a go
> with some limited guidance if no one else is working on it already. Looks
> like the behavior you noted comes from this line
> <https://github.com/scikit-learn/scikit-learn/blob/202b5321f1798c4980abf69ac8c0a0969f01a2ec/sklearn/utils/validation.py#L480>,
> where we're checking the array against the numpy object type when we'd like
> to check it against string and unicode types as well -- the [['a', 'b',
> 'c']] list in your example appears to be cast to the numpy unicode array
> type in your example by the time it reaches that line. Sound right?
>
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/10229#issuecomment-358173231>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz69hcymywNoXaDwoNalOeRc93uF3Uks5tLVg8gaJpZM4QwJIl>
> .
>

We wouldn't deprecate `check_array` entirely, but we would warn for two releases that "In the future, this data with dtype('Uxx') would be rejected because it is not of a numeric dtype."
ping @jnothman 

> This seems overly lenient and strange behaviour, as in #9342 where @qinhanmin2014 shows that check_array(['a', 'b', 'c'], dtype='numeric') works without error and produces an array of strings!

I think you mean #9835 (https://github.com/scikit-learn/scikit-learn/pull/9835#issuecomment-348069380) ?

Yes, from my perspective, if it is not intended, it seems a bug.
it seems memorising four digit numbers is not my speciality

Five now!
And I'm not entirely sure what my intended behavior was, but I agree with your assessment. This should error on strings.
I think, @amueller, for the next little while, the mere knowledge that a
number has five digits leaves the first with distinctly low entropy

Well, I guess it's one more bit, though ;)
@jnothman I'd be happy to give this a go with some limited guidance if no one else is working on it already. Looks like the behavior you noted comes from [this line](https://github.com/scikit-learn/scikit-learn/blob/202b5321f1798c4980abf69ac8c0a0969f01a2ec/sklearn/utils/validation.py#L480), where we're checking the array against the numpy object type when we'd like to check it against string and unicode types as well -- the `[['a', 'b', 'c']]` list in your example appears to be cast to the numpy unicode array type in your example by the time it reaches that line. Sound right?
I'd also be curious to hear what you had in mind in terms of longer term solution, i.e., what would replace `check_array` if deprecated?
> Perhaps we need a deprecation cycle
Something like that. Basically if dtype_numeric and array.dtype is not an
object dtype or a numeric dtype, we should raise.

On 17 January 2018 at 13:17, Ryan <notifications@github.com> wrote:

> @jnothman <https://github.com/jnothman> I'd be happy to give this a go
> with some limited guidance if no one else is working on it already. Looks
> like the behavior you noted comes from this line
> <https://github.com/scikit-learn/scikit-learn/blob/202b5321f1798c4980abf69ac8c0a0969f01a2ec/sklearn/utils/validation.py#L480>,
> where we're checking the array against the numpy object type when we'd like
> to check it against string and unicode types as well -- the [['a', 'b',
> 'c']] list in your example appears to be cast to the numpy unicode array
> type in your example by the time it reaches that line. Sound right?
>
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/10229#issuecomment-358173231>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz69hcymywNoXaDwoNalOeRc93uF3Uks5tLVg8gaJpZM4QwJIl>
> .
>

We wouldn't deprecate `check_array` entirely, but we would warn for two releases that "In the future, this data with dtype('Uxx') would be rejected because it is not of a numeric dtype."