Replace `cachedproperty` with `functools.cached_property` (>= 3.8)
I thought about this PR recently again. Typing `cachedproperty` might not work, but it can be replaced with `functools.cached_property`. We only need to `sys` guard it for `< 3.8`. This should work
```py
if sys.version_info >= (3, 8):
    from functools import cached_property
else:
    from astroid.decorators import cachedproperty as cached_property
```

Additionally, the deprecation warning can be limited to `>= 3.8`.

_Originally posted by @cdce8p in https://github.com/PyCQA/astroid/issues/1243#issuecomment-1052834322_
