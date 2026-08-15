Actually, whether adding a column works depends on how the columns were specified:
```python
import pandas as pd
from sklearn.compose import make_column_transformer

df = pd.DataFrame({
  'boro': ['Manhattan', 'Queens', 'Manhattan', 'Brooklyn', 'Brooklyn', 'Bronx'],
  'salary': [103, 89, 142, 54, 63, 219],
  'vegan': ['No', 'No','No','Yes', 'Yes', 'No']})

categorical = df.dtypes == object
preprocess = make_column_transformer(
    (StandardScaler(), ~categorical),
    (OneHotEncoder(), categorical))
preprocess.fit_transform(df)
df2 = df.copy()
df2['notused'] = 1
preprocess.transform(df2)
```
```python_tb
IndexingError  
```
And reordering the columns:
```python
preprocess.transform(df.loc[:, ::-1])
```
passes through the ColumnTransformer but what is passed on is wrong.

but
```python
categorical = ['boro', 'vegan']
continuous = ['salary']
preprocess = make_column_transformer(
    (StandardScaler(), continuous),
    (OneHotEncoder(), categorical))
preprocess.fit_transform(df)
df['notused'] = 1
preprocess.transform(df)
```

works, and reordering columns also works:
```python
preprocess.transform(df.loc[:, ::-1)
```
Similarly, reordering columns should work if you use names for indexing, but not if you use boolean masks. That's ... interesting ... behavior, I would say.
Four approaches I could think of:

1) Be strict and require that columns match exactly (with order). That would break code that currently works, but also might show some errors that currently hidden. Might be a bit inconvenient as it doesn't really allow subsetting columns flexibly.

2) Be strict and require that columns match exactly *unless* they are specified by names. Then it should work on currently working use-cases, but error on things that are currently silent bugs.

3) If the input is a pandas dataframe, always use the column names (from fit) to store the column identities, no matter how the user provided them originally, and allow reordering of columns and adding columns that are not used. Downside: behavior might change between when a numpy array is passed and when a dataframe is passed. I would need to think about this more.

4) Keep things the way they are, i.e silent bug if reordering on booleans and integers and erroring on adding columns on booleans and integers and things working as expected using string names.

As I said above, if ``remainder`` is used we probably shouldn't allow adding extra columns for ``transform`` if we do (though we could also just ignore all columns not present during fit).
From a user with an (admittedly ancient) usability background who very recently tripped over their own assumptions on named columns and their implications:
- I have/had a strong association of by-name implying flexible-ordering (and vice-versa)
- At the same time, I was oblivious of the fact that this implies different rules for how columns specified by name vs by index were handled, particularly with `remainder`
- I have a hard time remembering what works with one type of usage of the same parameter versus another, particularly in combination with other parameters

From this very subjective list, I would distill that:
- clarity and consistency beat convenience

My main wish would be for the whole Pipeline/Transformer/Estimator API to be as consistent as possible in the choice of which of the rules that @amueller laid out above should be in effect. Option number 1 seems to match this the closest. I don't quite understand the part "...inconvenient  as it doesn't really allow subsetting columns flexibly", however. Isn't it this flexibility (as I understand you mean between fit and transform) which only causes problems with other transformers? I can't see a practical use case for the flexibility to have more/fewer columns between fit and transform.

Reading my own ramblings (stream of consciousness indeed), I would not see a lot of harm for the end user in deprecating the ability to specify columns by name and only allow numeric indices/slices, because:
- If the user starts out with column names, it's easy for them to create indices to pass to `ColumnTransformer`
- Numeric indices intuitively imply fixed ordering, which I understand is a standard for other transformers anyway

The documentation could then refer users seeking more convenience to the contribution [sklearn-pandas](scikit-learn-contrib/sklearn-pandas).

So this is more or less a 180 degree change from my initial suggestion, but I found myself using a lot of `if`s even explaining the problem in the issue and pull request, which made me aware it might be possible to reduce complexity (externally and internally) a little bit.


Thank you for your input. I agree with most of your assessment, though not entirely with your conclusion. Ideally we'd get as much consistency and convenience as possible.
I also have a hard time wrapping my head around the current behavior, which is clearly not a great thing.

Adding extra columns during transform indeed would not be possible with any other transformer and would be a bad idea. However, if you think of ColumnTransformer going from "whatever was in the database / CSV" to something that's structured for scikit-learn, it makes sense to allow dropping columns from the test set that were not in the training set. Often the training set is collected in a different way then the test set and there might be extra columns in the test set that are not relevant to the model.
Clearly this could easily be fixed by dropping those before passing them into the ColumnTransformer, so it's not that big a deal.

I'm not sure why you wouldn't allow using strings for indexing. We could allow strings for indexing and still require the order to be fixed. This might not correspond entirely to your mental model (or mine) but I also don't see any real downside to allowing that if we test for consistency and have a good error message.

Generally I think it's desirable that the behavior is as consistent as possible between the different ways to specify columns, which is not what's currently the case.
Also: users will be annoyed if we forbid things that were allowed previously "just because" ;)
Good points. I did not really mean that clarity and convenience were a zero-sum-tradeoff to me (clarity begets convenience, the other way round... not so sure).

If ColumnTransformer wants to be used by users preparing raw data for scikit-learn ("pipeline ingestion adaptor"), as well as snugly inside a pipeline ("good pipeline citizen"), maybe it tries to be different things to different people? Not saying that it should be split up or anything, but this thought somehow stuck with me after re-reading the issue(s).

Maybe some sort of `relax_pipeline_compatibility=False` kwarg? (Yes, I know, "just make it an option", the epitome of lazy interface design -- the irony is not lost to me ;). But in this case, it would clean up a lot of those `if`s at least in its default mode while it still could be used in "clean up this mess" mode if needed. Although my preference would be to let the user do this cleanup themselves)

Regarding not allowing strings for indexing: ~~I suggest this because of (at least my) pretty strong intuitive understanding that by-name equals flexible ordering, and to keep other users from the same wrong assumption (admittedly subjective, would have to ask more users).~~ Edit: reading comprehension. :) I guess it depends on how many users have this assumption and would have to be "corrected" by the doc/errors (if we end up correcting most of them, we might be the ones in need of correcting).

Regarding taking something away from users ([relevant xkcd - of course!](https://xkcd.com/1172/)). True, but it's still so new that they might not have used it yet... ;)
I am happy with 1 as an interim solution at least. I would also consider
allowing appended columns in a DataFrame. I would also consider 3 for the
future but as you point out we would be making a new requirement that you
need to transform a DataFrame if you fit a DataFrame

I quite like option one, especially since we can first warn the user of the change in the order and say we won't be accepting this soon.

Option 3 worries me cause it's an implicit behavior which the user might not understand the implications of.

I understand @amueller 's point on the difference between test and train sets, but I rather leave input validation to the user and not enter that realm in sklearn. That said, I'd still half-heartedly be okay with option 2. 
I'm fine with 1) if we do a deprecation cycle. I'm not sure it's convenient for users.
Right now we allow extra columns in the test set in some cases that are ignored. If we deprecate that and then reintroduce that it's a bit weird and inconvenient. So I'm not sure if doing 1 first and then doing 3 is good because we send weird signals to the user. But I guess it wouldn't be the end of the world?

@adrinjalali I'm not sure I understand what you mean by input validation.
Right now we have even more implicit behavior because the behavior in 3 is what we're doing right now if names are passed but not otherwise.

Should we try and implement this now that the release is out? @adrinjalali do you want to take this? @NicolasHug ?
I can also give it a shot.

I think clarifying this will be useful on the way to feature names
I can take this @amueller 