I confirmed that this is no longer an issue in marshmallow 3. I was able to reproduce this with python 2 and 3 using the latest version of marshmallow 2.
`next(iter(...))` is not a safe operation for generators.

```py
def gen():
    yield 1
    yield 2

x = gen()
next(iter(x))
# 1
list(x)
# [2]
```

I suspect `list` would be an acceptable solution. If it was a performance concern we could use `itertools.tee` to copy the generator before peeking at the first item.
`next(iter(...))` is apparently fine because `obj` is guaranteed to be a list here:

https://github.com/marshmallow-code/marshmallow/blob/2.x-line/src/marshmallow/schema.py#L489

It's just that usage of `Schema._update_fileds` in `Nested` ignores the requirement.
