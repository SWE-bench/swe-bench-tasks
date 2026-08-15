Now there is no error occurred, this also happened in `HashingVectorizer` and`TfidfVectorizer`
I think we can add an error message in `VectorizerMixin`？
Since `CountVectorizer`, `HashingVectorizer` and `andTfidfVectorizer` are inherited from `VectorizerMixin`, we can add a validation check in `VectorizerMixin`. I think using Python [property](https://docs.python.org/2/library/functions.html#property) is a good way. 
For example:
```python
#within VectorizerMixin
@property
def ngram_range(self):
    return self._ngram_range

# alternatively, a cleaner style:
# from operator import attrgetter 
# ngram_range = property(attrgetter('_ngram_range'))

@ngram_range.setter
def ngram_range(self, value):
    # raise ValueError if the input is invalid.
    self.__ngram_range = value
```
I would like to work on it. I'm a new contributor, so any suggestions are welcome :)

References:
[1] https://docs.python.org/2/library/functions.html#property
[2] http://stackoverflow.com/a/2825580/6865504
Hmm... We conventionally perform validation in `fit`, for good or bad.

On 5 April 2017 at 03:29, neyanbhbin <notifications@github.com> wrote:

> Since CountVectorizer, HashingVectorizer and andTfidfVectorizer are
> inherited from VectorizerMixin, we can add a validation check in
> VectorizerMixin. I think using Python property
> <https://docs.python.org/2/library/functions.html#property> is a good way.
> For example:
>
> #within VectorizerMixin@propertydef ngram_range(self):
>     return self._ngram_range
> # alternatively, a cleaner style:# from operator import attrgetter # ngram_range = property(attrgetter('_ngram_range'))
> @ngram_range.setterdef ngram_range(self, value):
>     # raise ValueError if the input is invalid.
>     self.__ngram_range = value
>
> I would like to work on it. I'm a new contributor, so any suggestions are
> welcome :)
>
> References:
> [1] https://docs.python.org/2/library/functions.html#property
> [2] http://stackoverflow.com/a/2825580/6865504
>
> —
> You are receiving this because you are subscribed to this thread.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/8688#issuecomment-291573285>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz6w2mFZFCsFTlYO4O37FgynC0FVZSks5rsn4BgaJpZM4Mw7gK>
> .
>

I think this case is same as the validation of [min_df, max_df](https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/feature_extraction/text.py#L676) and [max_features](https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/feature_extraction/text.py#L678)

> Hmm... We conventionally perform validation in `fit`, for good or bad.
That's there for historical reasons. If we wrote that code today, it would
happen in fit.

On 6 April 2017 at 15:41, neyanbhbin <notifications@github.com> wrote:

> I think this case is same as the validation of min_df, max_df
> <https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/feature_extraction/text.py#L676>
> and max_features
> <https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/feature_extraction/text.py#L678>
>
> Hmm... We conventionally perform validation in fit, for good or bad.
>
> —
> You are receiving this because you commented.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/8688#issuecomment-292074352>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz6-GA6tiQRNkvKJtfJRyPeFi55peiks5rtHsTgaJpZM4Mw7gK>
> .
>

In particular, any validation should not *only* happen in __init__ because
things can change between __init__ and fit.

On 6 April 2017 at 16:25, Joel Nothman <joel.nothman@gmail.com> wrote:

> That's there for historical reasons. If we wrote that code today, it would
> happen in fit.
>
> On 6 April 2017 at 15:41, neyanbhbin <notifications@github.com> wrote:
>
>> I think this case is same as the validation of min_df, max_df
>> <https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/feature_extraction/text.py#L676>
>> and max_features
>> <https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/feature_extraction/text.py#L678>
>>
>> Hmm... We conventionally perform validation in fit, for good or bad.
>>
>> —
>> You are receiving this because you commented.
>> Reply to this email directly, view it on GitHub
>> <https://github.com/scikit-learn/scikit-learn/issues/8688#issuecomment-292074352>,
>> or mute the thread
>> <https://github.com/notifications/unsubscribe-auth/AAEz6-GA6tiQRNkvKJtfJRyPeFi55peiks5rtHsTgaJpZM4Mw7gK>
>> .
>>
>
>

Oh, I see. I might oversimplify the problem here. Sorry. 
So is it similar with [raw_documents](https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/feature_extraction/text.py#L828) in `fit`(or `fit_transform`)? Or we need a more common function to deal with the invalid parameters, including `max_features`, `min_df`, `max_df` and `ngram_range`?

> That's there for historical reasons. If we wrote that code today, it would
happen in fit.
factoring out validation into a separate function would be welcome imo

On 7 Apr 2017 3:36 am, "neyanbhbin" <notifications@github.com> wrote:

> Oh, I see. I might oversimplify the problem here. Sorry.
> So is it similar with raw_documents
> <https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/feature_extraction/text.py#L828>
> in fit(or fit_transform)? Or we need a more common function to deal with
> the invalid parameters, including max_features, min_df, max_df and
> ngram_range?
>
> That's there for historical reasons. If we wrote that code today, it would
> happen in fit.
>
> —
> You are receiving this because you commented.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/8688#issuecomment-292250403>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz6-prUMGhwf7GnzUVSBtcHRAomG_eks5rtSKVgaJpZM4Mw7gK>
> .
>
