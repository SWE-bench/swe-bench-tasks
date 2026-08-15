I'd like to try this one.
If you haven't contributed before, I suggest you try an issue labeled "good first issue". Though this one isn't too hard, eigher.
@amueller 
I think I can handle it.
So we want something like this right?

    enc.fit([['male',0], ['female', 1]])
    enc.get_feature_names()

    >> ['female', 'male', 0, 1]

Can you please give an example of how original feature names can map to new feature names? I have seen the `get_feature_names()` from PolynomialFeatures, but I don't understand what that means in this case.
I think the idea is that if you have multiple input features containing the
value "hello" they need to be distinguished in the feature names listed for
output. so you prefix the value with the input feature name, defaulting to
x1 etc as in polynomial. clearer?

@jnothman Is this what you mean?

    enc.fit(  [ [ 'male' ,    0,  1],
                 [ 'female' ,  1 , 0]  ] )

    enc.get_feature_names(['one','two','three'])

    >> ['one_female', 'one_male' , 'two_0' , 'two_1' , 'three_0' , 'three_1']


And in case I don't pass any strings, it should just use `x0` , `x1` and so on for the prefixes right?
Precisely.

>
>

I like the idea to be able to specify input feature names.

Regarding syntax of combining the two names, as prior art we have eg `DictVectorizer` that does something like `['0=female', '0=male', '1=0', '1=1']` (assuming we use 0 and 1 as the column names for arrays) or Pipelines that uses double underscores (`['0__female', '0__male', '1__0', '1__1']`). Others? 
I personally like the `__` a bit more I think, but the fact that this is used by pipelines is for me actually a reason to use `=` in this case. Eg in combination with the ColumnTransformer (assuming this would use the `__` syntax like pipeline), you could then get a feature name like `'cat__0=male'` instead of `'cat__0__male'`.
Additional question:

- if the input is a pandas DataFrame, do we want to preserve the column names (to use instead of 0, 1, ..)? 
  (ideally yes IMO, but this would require some extra code as currently it is not detected whether a DataFrame is passed or not, it is just coerced to array)
no, we shouldn't use column names automatically. it's hard for us to keep
them and easy for the user to pass them.

>  it's hard for us to keep them

It's not really 'hard':

```
class CategoricalEncoder():

    def fit(self, X, ...):
        ...
        if hasattr(X, 'iloc'):
            self._input_features = X.columns
        ...

    def get_feature_names(self, input_features=None):
        if input_features is None:
            input_features = self._input_features
        ...
```

but of course it is added complexity, and more explicit support for pandas dataframes, which is not necessarily something we want to add (I just don't think 'hard' is the correct reason :-)).

But eg if you combine multiple sets of columns and transformers in a ColumnTransformer, it is not always that straightforward for the user to keep track of IMO, because you then need to combine the different sets of selected column into one list to pass to `get_feature_names`.
No, then you just need get_feature_names implemented everywhere and let
Pipeline's (not yet) implementation of get_feature_names handle it for you.
(Note: There remain some problems with this design in a meta-estimator
context.) I've implemented similar within the eli5 package, but we also got
somewhat stuck when it came to making arbitrary decisions about how to make
feature names for linear transforms like PCA. A structured representation
rather than a string name might be nice...

On 23 November 2017 at 10:00, Joris Van den Bossche <
notifications@github.com> wrote:

> it's hard for us to keep them
>
> It's not really 'hard':
>
> class CategoricalEncoder():
>
>     def fit(self, X, ...):
>         ...
>         if hasattr(X, 'iloc'):
>             self._input_features = X.columns
>         ...
>
>     def get_feature_names(self, input_features=None):
>         if input_features is None:
>             input_features = self._input_features
>         ...
>
> but of course it is added complexity, and more explicit support for pandas
> dataframes, which is not necessarily something we want to add (I just don't
> think 'hard' is the correct reason :-)).
>
> But eg if you combine multiple sets of columns and transformers in a
> ColumnTransformer, it is not always that straightforward for the user to
> keep track of IMO, because you then need to combine the different sets of
> selected column into one list to pass to get_feature_names.
>
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub
> <https://github.com/scikit-learn/scikit-learn/issues/10181#issuecomment-346495657>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAEz62rb6pYYTi80NzltL4u4biA3_-ARks5s5KePgaJpZM4Ql59C>
> .
>
