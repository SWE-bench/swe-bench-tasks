This is a `pylint` issue. However, I'd like to reframe it to:
```
pylint --errors-only --disable=E0401 test.py
```
not working as intended.

Due to the limitation of argument parsers arguments will be parser consecutively. So if you first disable an error message, but then enable all error message it will be re-enabled. There is not that much we can do about that.
However, we currently parse ``--errors-only`` at the end of all configuration parsing. Making it impossible to combine it with a specific disable even if you order the arguments like in my example. That should be fixed.

For contributors: this can be done by creating a new `_CallableAction` for it and setting that as its `type`.
Are we interpreting --errors-only as an enable or a disable? If it's a disable (my inclination) then order is irrelevant because we're looking at two disables.
I agree with @jacobtylerwalls it should definitely be considered like a shortcut for ``--disable=W,C,R``.
It's:

https://github.com/PyCQA/pylint/blob/2ee15d3c504ec1d0ebd210dc635ec440b98f65ef/pylint/lint/pylinter.py#L490

We should turn that function into an action.
Firstly, apologies for initially posting to the wrong project (late night bug posts!) 

> I agree with @jacobtylerwalls it should definitely be considered like a shortcut for `--disable=W,C,R`.

I assumed _--disable=W,C,R,E0401_ == _--errors-only --disable=E0401_

At least the "long form" is a work around.
