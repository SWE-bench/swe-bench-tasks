To be sure, the current docstring says:

```
If a callable is passed it is used to extract the sequence of features
out of the raw, unprocessed input.
```

"Unprocessed" seems to mean that even `input=` is ignored, but this is not obvious.

I'll readily agree that's the wrong behaviour even with that docstring.

On 20 October 2015 at 22:59, Lars notifications@github.com wrote:

> To be sure, the current docstring says:
> 
> ```
> If a callable is passed it is used to extract the sequence of features
> out of the raw, unprocessed input.
> ```
> 
> "Unprocessed" seems to mean that even input= is ignored, but this is not
> obvious.
> 
> —
> Reply to this email directly or view it on GitHub
> https://github.com/scikit-learn/scikit-learn/issues/5482#issuecomment-149541462
> .

I'm a new contributor, i'm interested to work on this issue. To be sure, what is expected is improving the docstring on that behavior ?

I'm not at all sure. The behavior is probably a bug, but it has stood for so long that it's very hard to fix without breaking someone's code.

@TTRh , did you have had some more thoughts on that? Otherwise, I will give it a shot and clarify how the input parameter is ought to be used vs. providing input in the fit method.

Please go ahead, i didn't produce anything on it !

@jnothman @larsmans commit is pending on the docstring side of things.. after looking at the code, I think one would need to introduce a parameter like preprocessing="none" to not break old code. If supplying a custom analyzer and using inbuilt preprocessing is no boundary case, this should become a feature request?

I'd be tempted to say that any user using `input='file'` or `input='filename'` who then passed text to `fit` or `transform` was doing something obviously wrong. That is, I think this is a bug that can be fixed without notice. However, the correct behaviour still requires some definition. If we load from file for the user, do we decode? Probably not. Which means behaviour will differ between Py 2/3. But that's the user's problem.

