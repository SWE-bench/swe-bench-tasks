Thank you for opening the issue.
I don't believe `Unknown().as_string()` is ever called regularly. AFAIK it's only used during inference. What should the string representation of an `Unknown` node be? So not sure this needs to be addressed.
Probably just `'Unknown'`.
It's mostly only a problem when we do something like this:

```python
inferred = infer(node)
if inferred is not Uninferable:
    if inferred.as_string().contains(some_value):
        ...
```
So for the most part, as long as it doesn't crash we're good.