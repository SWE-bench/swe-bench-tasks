"TypeError: unsupported format string passed to NoneType.__format__" while running type inference in version 2.12.x
### Steps to reproduce

I have no concise reproducer. Exception happens every time I run pylint on some internal code, with astroid 2.12.10 and 2.12.12 (debian bookworm). It does _not_ happen with earlier versions of astroid (not with version 2.9). The pylinted code itself is "valid", it runs in production here.

### Current behavior

When running pylint on some code, I get this exception:
```
Traceback (most recent call last):
  File "/usr/lib/python3/dist-packages/pylint/utils/ast_walker.py", line 90, in walk
    callback(astroid)
  File "/usr/lib/python3/dist-packages/pylint/checkers/classes/special_methods_checker.py", line 183, in visit_functiondef
    inferred = _safe_infer_call_result(node, node)
  File "/usr/lib/python3/dist-packages/pylint/checkers/classes/special_methods_checker.py", line 42, in _safe_infer_call_result
    value = next(inferit)
  File "/usr/lib/python3/dist-packages/astroid/nodes/scoped_nodes/scoped_nodes.py", line 1749, in infer_call_result
    yield from returnnode.value.infer(context)
  File "/usr/lib/python3/dist-packages/astroid/nodes/node_ng.py", line 159, in infer
    results = list(self._explicit_inference(self, context, **kwargs))
  File "/usr/lib/python3/dist-packages/astroid/inference_tip.py", line 45, in _inference_tip_cached
    result = _cache[func, node] = list(func(*args, **kwargs))
  File "/usr/lib/python3/dist-packages/astroid/brain/brain_builtin_inference.py", line 956, in _infer_str_format_call
    formatted_string = format_template.format(*pos_values, **keyword_values)
TypeError: unsupported format string passed to NoneType.__format__
```

### Expected behavior

TypeError exception should not happen

### `python -c "from astroid import __pkginfo__; print(__pkginfo__.version)"` output

2.12.10,
2.12.12
