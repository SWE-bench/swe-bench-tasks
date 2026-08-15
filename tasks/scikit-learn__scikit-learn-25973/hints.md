The internal algorithm will use the `cv` parameter in a `for` loop. If `cv` is a generator, it will be consumed at the first iteration only. Later it trigger the error because we did not complete the other iteration of the `for` loop.

Passing a list (e.g. `cv=list(splits)`) will solve the problem because we can reuse it.

I think that there is no obvious way to make a clone of the generator. Instead, I think that the best solution would be to alternate the documentation and mention that the iterable need to be a list and not a generator.
Thank you! Passing a list works. Updating the documentation seems like a good idea.
Hi, is anyone working on updating the documentation? If not I'm willing to do that. It should be an API documentation for the ·SequentialFeatureSelector· class right? For instance, add
```
NOTE that when using an iterable, it should not be a generator.
```
By the way, is it better to also add something to `_parameter_constraints`? Though that may involve modifying `_CVObjects` or create another class such as `_CVObjectsNotGenerator` and use something like `inspect.isgenerator` to make the check.
Thinking a bit more about it, we could call `check_cv` on `self.cv` and transform it into a list if the output is a generator. We should still document it since it will take more memory but we would be consistent with other cv objects.

/take
@glemaitre  Just to make sure: should we

- note that a generator is accepted but not recommended
- call `check_cv` to transform `self.cv` into a list if it is a generator
- create nonregression test to make sure no exception would occur in this case

or

- note that a generator is not accepted
- do not do any modification to the code
We don't need a warning, `check_cv` already accepts an iterable, and we don't warn on other classes such as `GridSearchCV`. The accepted values and the docstring of `cv` should be exactly the same as `*SearchCV` classes.
Okay I understand, thanks for your explanation.