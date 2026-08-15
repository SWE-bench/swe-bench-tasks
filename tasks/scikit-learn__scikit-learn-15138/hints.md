I think that I added this in the early stage of the PR and we ruled this out.
I agree that it existed at one point. I think it can be considered now in
any case.

`use_feature_in_secondary` might be a long name. At that time, I named it `passthrough`.
Would it be better.
> I think that I added this in the early stage of the PR and we ruled this out.

Could you please summarize the reason? thanks @glemaitre
The reason was to make the PR simpler from what I am reading now.
So I think that we can go ahead to make a new PR.
> At that time, I named it passthrough.

Let's use this name.
Hi all --  I'd be glad to take a stab at putting a PR in for this.
@jcusick13 Go for it :)
> `use_feature_in_secondary` might be a long name. At that time, I named it `passthrough`.

@glemaitre  i think original name is better, `passthrough`  is hard to understand, pass through what? pass through original features. 
maybe name it as `use_raw_features`?
#response_container_BBPPID{font-family: initial; font-size:initial; color: initial;}IMO it is to long
We use "passthrough" with similar semantics in ColumnTransformer

(albeit with different syntax and context: it's not a parameter there)
