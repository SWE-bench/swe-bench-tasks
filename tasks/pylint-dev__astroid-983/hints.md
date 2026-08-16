Makes sense.

This happens because the inference for functions looks through each return value here (https://github.com/PyCQA/astroid/blob/629c92db2dc1b016f4bf47645c95c42e65fd3bd6/astroid/scoped_nodes.py#L1558) and tries to infer the result from there. But since functions like this don't have an explicit return value, the inference gets into `raise_if_nothing_inferred` over here (https://github.com/PyCQA/astroid/blob/ac3e82e9bd8678086325a71a927a06bbc43d415e/astroid/decorators.py#L140), resulting in the exception you see. 
What should we infer for a function that always raises an exception? I don't think it should be `None`. Uninferable I guess?

---

I tried to add this, but It caused a cascade of errors where we are looking for Uninferable instead of const.None
@brycepg I would say it should return `Uninferable`, as raising exceptions is not necessarily returning a value from the function. Although we'd want some mechanism to get what exceptions a function could raise.

Regarding your last statement, you mean you added `Uninferable` for functions that raise exceptions or for functions that return `None`? Which of these failed with the cascade of errors?
@PCManticore I made functions that do not have any return/yield nodes infer to `None` instead of `Uninferable`, and it broke a lot of tests.