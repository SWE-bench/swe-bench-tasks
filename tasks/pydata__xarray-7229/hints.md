Original looks like this:
```python
# keep the attributes of x, the second parameter, by default to
# be consistent with the `where` method of `DataArray` and `Dataset`
keep_attrs = lambda attrs, context: attrs[1]
```

New one looks like this:
```python
# keep the attributes of x, the second parameter, by default to
# be consistent with the `where` method of `DataArray` and `Dataset`
keep_attrs = lambda attrs, context: getattr(x, "attrs", {})
```

I notice that the original return `attrs[1]` for some reason but the new doesn't. I haven't tried but try something like this:
```python
def keep_attrs(attrs, context):
    attrs_ = getattrs(x, "attrs", {})
    if attrs_:
        return attrs_[1]
    else:
        return attrs_
```
I don't get where the x comes from though, seems scary to get something outside the function scope like this.
Anything that uses `attrs[1]` and the `_get_all_of_type` helper is going to be hard to guarantee the behavior stated in the docstring, which is that we take the attrs of `x`. If `x` is a scalar, then `_get_all_of_type` returns a list of length 2 and `attrs[1]` ends up being the attrs of `y`. I think we may want to rework this, will try a few things later today.
see also the suggestions in https://github.com/pydata/xarray/pull/6461#discussion_r1004988864 and https://github.com/pydata/xarray/pull/6461#discussion_r1005023395