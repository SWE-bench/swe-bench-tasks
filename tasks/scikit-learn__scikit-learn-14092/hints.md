I have developed a framework, experimenting with parameter verification: https://github.com/thomasjpfan/skconfig (Don't expect the API to be stable)

Your idea of using a simple dict for union types is really nice!

Edit: I am currently trying out another idea. I'll update this issue when it becomes something presentable.
If I understood correctly your package is designed for a sklearn user, who has to implement its validator for each estimator, or did I get it wrong ?
I think we want to keep the param validation inside the estimators.

> Edit: I am currently trying out another idea. I'll update this issue when it becomes something presentable.

maybe you can pitch me and if you want I can give a hand :)
I would have loved to using the typing system to get this to work:

```py
def __init__(
    self,
    C: Annotated[float, Range('[0, Inf)')],
    ...)
```

but that would have to wait for [PEP 593](https://www.python.org/dev/peps/pep-0593/). In the end, I would want the validator to be a part of sklearn estimators. Using typing (as above) is a natural choice, since it keeps the parameter and its constraint physically close to each other.

If we can't use typing, these constraints can be place in a `_validate_parameters` method. This will be called at the beginning of fit to do parameter validation. Estimators that need more validation will overwrite the method, call `super()._validate_parameters` and do more validation. For example, `LogesticRegression`'s `penalty='l2'` only works for specify solvers. `skconfig` defines a framework for handling these situations, but I think it would be too hard to learn.
>  Using typing (as above) is a natural choice

I agree, and to go further it would be really nice to use them for the coverage to check that every possible type of a parameter is covered by tests

> If we can't use typing, these constraints can be place in a _validate_parameters method. 

This is already the case for a subset of the estimators (`_check_params` or `_validate_input`). But it's often incomplete.

> skconfig defines a framework for handling these situations, but I think it would be too hard to learn.

Your framework does way more than what I proposed. Maybe we can do this in 2 steps:
First, a simple single param check which only checks its type and if its value is acceptable in general (e.g. positive for a number of clusters). This will raise a standard error message
Then a more advanced check, depending on the data (e.g. number of clusters should be < n_samples) or consistency across params (e.g. solver + penalty). These checks require more elaborate error messages.

wdyt ?