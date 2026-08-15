You're saying we can't pickle the tokenizer, pickling the vectorizer is fine, right? The title says vectorizer.
We could rewrite it to allow pickling the tokenizer if we want to support that. There doesn't really seem a reason not to do that, but it's not a very common use-case, right?

And I would prefer the fix 2.
All estimators pickle and we test that. Even though lambdas are used in some places. The reason there is an issue here is because you're trying to pickle something that's more of an internal data structure (though it's a public interface).
I edited the title - you're right. I do not know how common a use-case it is - I happen to be saving the tokenizer and vectorizer in a pytorch model and came across this error, so I thought it was worth reporting and maybe solving (maybe I'm wrong). 

So far as I can tell, there are six lambdas in what I believe to be the offending file at https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/feature_extraction/text.py , which isn't many.
I think it's fine to fix this. I guess I just wanted to say this is not really a bigger issue and basically everything in sklearn pickles but you found an object that doesn't and we should just fix that object ;)
I made a PR that fixes the issue but I did not add a test case - where would be appropriate?
> Remove the use of the lambdas in the vectorizer and replace them with locally def'd functions. 

+1 particularly that some of those are assigned to a named variable, which is not PEP8 compatible.