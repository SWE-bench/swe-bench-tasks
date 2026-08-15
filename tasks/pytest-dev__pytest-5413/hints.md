> Any chance the behavior could be changed to eliminate this gotcha?

What do you suggest?

Proxying through to the exceptions `__str__`?
Hi @fiendish,

Indeed this is a bit confusing.

Currently `ExceptionInfo` objects (which is `pytest.raises` returns to the context manager) implements `__str__` like this:

https://github.com/pytest-dev/pytest/blob/9f8b566ea976df3a3ea16f74b56dd6d4909b84ee/src/_pytest/_code/code.py#L537-L542

I don't see much use for this, I would rather it didn't implement `__str__` at all and let `__repr__` take over, which would show something like:

```
<ExceptionInfo LookupError tb=10>
```

Which makes it more obvious that this is not what the user intended with `str(e)` probably.

So I think a good solution is to simply delete the `__str__` method.

Thoughts?

Also, @fiendish which Python version are you using?
> So I think a good solution is to simply delete the `__str__` method.

Makes sense to me.


Python 3.7.3

My ideal outcome would be for str(e) to act the same as str(e.value), but I can understand if that isn't desired.
> My ideal outcome would be for str(e) to act the same as str(e.value), but I can understand if that isn't desired.

I understand, but I think it is better to be explicit here, because users might use `print(e)` to see what `e` is, assume it is the exception value, and then get confused later when it actually isn't (an `isinstance` check or accessing `e.args`).
+1 for deleting the current `__str__` implementation
-1 for proxying it to the underlying `e.value`

the `ExceptionInfo` object is not the exception and anything that makes it look more like the exception is just going to add to the confusion