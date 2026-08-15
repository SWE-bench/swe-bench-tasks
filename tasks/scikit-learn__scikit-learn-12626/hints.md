It's not very nice, is it!! I don't know what to do...
we said we might break it... I feel this is a good reason to?
Basically either that or I have to add to my book (and every tutorial I ever give) "but be careful, they go in a different order for some reason"
Then is it better to break in 0.20.1 or 0.21??

Breaking in 0.20.1 has the benefit of fewer people having had used them by the time of the release of the change.
I agree, I'd favor 0.20.1
And which of the two would you change?

We discussed this several times (at least, I remember raising the question several times about what to do with this consistency, or whether we are fine with it), and I think we also swapped a few times the order during the lifetime of the PR.

As far as I remember, the reason is that for `make_column_transformer`, this is the logical order, and for `ColumnTransformer`, it is somewhat following Pipeline/FeatureUnion
Right now I can't recall why this is the logical order for `make_column_transformer`...
If we change the order in `make_column_transformer`, maybe we can use some magic (i.e. heuristics) to make it backwards compatible to 0.20.0, with a warning.

I.e.
```py
if hasattr(tup[1], 'fit') or tup[1] in ('drop', 'passthrough'):
    warnings.warn(DeprecationWarning,
                  'make_column_transformer arguments should be '
                  '(transformer, columns). (columns, transformer) was passed; '
                  'its support is deprecated and will be removed in version 0.23.')
    tup = (tup[1], tup[0])
```

the `hasattr(tup[1], 'fit')` part seems fine to me, but I'd worry about checking for string literals since it'll introduce a bug if the user passes `('drop', 'passthrough')` as the tuple.

I also don't think we'd need to keep this until v0.23, since it is indeed marked as experimental.
Yeah I remember the back-and-forth but I didn't remember that the outcome is inconsistent - or maybe then I didn't think it was that bad? Explaining it seems pretty awkward, though....
> I'd worry about checking for string literals

We can also check the other element to be sure it is not one of the allowed ones. That would only mean we miss a deprecation warning in that corner case of `('drop', 'passthrough')` (and for that it would then be a hard break ..). I don't think that should keep us from doing it though (if we decide we want to).

---

So options:

1. Do nothing (keep inconsistency), but for example we could provide more informative error messages (we should be able to infer rather easily if a user had the wrong order, similarly as we would do for a deprecation warning)
2. Change order of `ColumnTransformer` to be `(name, columns, transformer)` instead of `(name, transformer, columns)`. 
  For consistency with Pipeline/FeatureUnion, I think the most important part is that the first element is the name, the rest is not identical anyway.
3. Change the order of `make_column_transformer` to be `(transformer, columns)` instead of the current `(columns, transformer)`.

You are all rather thinking of option 3 I think?

Option 3 would certainly have less impact on the implementation than option 2.

Personally, I think the `(columns, transformer)` order of `make_column_transformer` reads more naturally than the other way around, so I would be a bit sad to see that go (but I also completely understand the consistency point ..)
I was thinking about 3 but don't have a strong preference between 2 and 3.
I guess what's more natural depends on your mental model and whether you think the primary object is the transformer or the columns (and I'm not surprised that @jnothman and me possibly think of the transformer as the primary object and you think of the columns as the primary object ;).

But really not a strong preference for 2.
I don't think it matters much. I think columns first might be more
intuitive.

If you're not working on it, I could give this a try. Are we going for option 2 then? I'd probably prefer `transformer, columns` since `columns` is probably the longest/most variable input parameter, and having it at the end helps with the readability of the code, and it's less change from the status quo of the code, but absolutely no hard feelings. 
Let's go with that. Thanks!!

I pretty much like 1. Using it, I got the same feeling but actually I find the current transformer more human readable while the change will not be (at least imo). 
I don't like 1 because it's inconsistent and hard to explain. It puts additional cognitive load on users for no reason. It makes it harder to change code.

@glemaitre you mean you find the current ``make_column_transformer`` more human readable, right? The ``ColumnTransformer`` doesn't change.
So @glemaitre are you saying you find the interface optimal for both ColumnTransformer and make_column_transformer? Can you try explain why?
Actually, looking at it again, I am split. I certainly find the current implementation of the `make_column_transformer` more natural.

So by changing `ColumnTransformer` it is only surprising if you are expecting that the estimator should come in second position alike in `Pipeline`. But anyway those two classes are different so it might not be that bad if actually they look different. So (2) would be my choice if we gonna change something.


I suspect this decision is fairly arbitrary. Users will consider natural whatever we choose. This will be far from the biggest wtf in our API!!
I don't have a strong opinion as long as it's consistent and the name comes first.
@jnothman now I'm curious what you consider the biggest wtf ;)
> now I'm curious what you consider the biggest wtf ;)

Well looking at ColumnTransformer construction alone, I'm sure users will wonder why weights are a separate parameter, and why they need these tuples in the first place, rather than having methods that allow them to specify `add(transformer=Blah(), column=['foo', 'bar'], weight=.5)` (after all, such a factory approach would almost make `make_column_transformer` redundant)...
One small argument in favour of 2 is that "ColumnTransformer" is a mnemonic for `(column, transformer)`.
So is that a consensus now? Should I change it?
> I'd probably prefer transformer, columns since columns is probably the longest/most variable input parameter, and having it at the end helps with the readability of the code

Just to answer to this argument. I think this quite depends on how your code is written, because it can perfectly be the other way around. Eg on the slides of Oliver about the new features, there was a fragment like:

```
numerical_columns = ... (longer selection based on the dtypes)
categorical_columns = ... 

preprocessor = make_column_transformer(
    (numerical_columns, make_pipeline(
        SimpleImputer(...),
        KBinsDiscretizer(...))
    ),
    (categorical_columns, make_pipeline(
        SimpleImputer(...),
        OneHotEncoder(...))
    )
)
```

So here, it is actually the transformer that is longer. But of course, you can perfectly define those before the `make_column_transformer` as well. But so just saying that this depends on the code organisation.
How are we gonna settle this? @ogrisel do you have an opinion? I kinda also expect from ``Pipeline`` and ``FeatureUnion`` that the estimator is second. But really I don't care that much...
Make it match the name I reckon: column-transformer.

For historical clarity: based on discussion in the PR https://github.com/scikit-learn/scikit-learn/pull/12396, we decided in the end to do it the other way around as decided on above (so `transformer, columns`). 
The reason is mainly due to technical and user-facing complexity to properly deprecate the current order in master for `ColumnTransfomer`, while it will be much easier to limit the change to the factory function `make_column_transformer`, but see the linked PR for more details.
