Actually, it seems a decorator is a red herring here, because I get the same off by one issue simply parsing a call

```python
source = """\
f(a=2,
   b=3,
)
"""

[call] = ast.parse(source).body
print("ast", call.lineno, call.end_lineno)

[call] = astroid.parse(source).body
print("astroid", call.fromlineno, call.tolineno)
```

which outputs

```
ast 1 3
astroid 1 2
```
Okay, this seems to be caused by the implementation of `NodeNG.tolineno` which uses the last line of the *child* to approximate the last line of the parent:

https://github.com/PyCQA/astroid/blob/03efcc3f86b88bab3080fe69119ee4c69e4afd0a/astroid/nodes/node_ng.py#L437-L446

Once possible fix is to override `tolineno` in `Call`. Wdyt?
> this seems to be caused by the implementation of NodeNG.tolineno which uses the last line of the child to approximate the last line of the parent:

Naive question, would it be possible to use the last line of the node instead, directly in NodeNG ?
Yeah, I think that should work with a caveat that the `ast` module only reports end line/column since Python 3.8. I'll draft a PR.
@superbobry I was looking at `tolineno` recently. I was wondering if it would make sense to add a check for >= 3.8 and then just use the `end_lineno` attribute that was added recently. No need to reinvent the wheel on those versions.

Perhaps that's a bit out of the scope of the PR you were going to draft, but it might help!