@cdce8p Just thinking out loud: can we also use a type guard to define `cached_property`? Would `mypy` pick up on that? 
> @cdce8p Just thinking out loud: can we also use a type guard to define `cached_property`? Would `mypy` pick up on that?

Not completely sure what you want to do with that.

On other thing, I just saw that we don't set the `python-version` for mypy. If we do that, we probably need to do some more workarounds to tell mypy `cachedproperty` is equal to `cached_property`. Adding `TYPE_CHECKING` could work
```py
if sys.version_info >= (3, 8) or TYPE_CHECKING:
    from functools import cached_property
else:
    from astroid.decorators import cachedproperty as cached_property
```