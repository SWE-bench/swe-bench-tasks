`.arguments` property ignores keyword-only args, *args, and **kwargs
```python
>>> from astroid import extract_node
>>> node = extract_node("""def a(*args, b=None, c=None, **kwargs): ...""")
>>> node.args.arguments
[]
```

Expected to find all the arguments from the function signature.

The wanted data can be found here:

```python
>>> node.args.vararg
'args'
>>> node.args.kwarg
'kwargs'
>>> node.args.kwonlyargs
[<AssignName.b l.1 at 0x1048189b0>, <AssignName.c l.1 at 0x104818830>]
```

Discussed at https://github.com/pylint-dev/pylint/pull/7577#discussion_r989000829.

Notice that positional-only args are found for some reason 🤷 
