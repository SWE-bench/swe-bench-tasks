Crash when inferring `str.format` call involving unpacking kwargs
When parsing the following file:

<!--
 If sharing the code is not an option, please state so,
 but providing only the stacktrace would still be helpful.
 -->

```python
class A:
    def render(self, audit_log_entry: AuditLogEntry):
        return "joined team {team_slug}".format(**audit_log_entry.data)



```

pylint crashed with a ``AstroidError`` and with the following stacktrace:
```
Traceback (most recent call last):
  File "/Users/.../astroid/astroid/inference_tip.py", line 38, in _inference_tip_cached
    result = _cache[func, node]
KeyError: (<function _infer_str_format_call at 0x1064a96c0>, <Call l.3 at 0x106c452d0>)

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/Users/.../pylint/pylint/lint/pylinter.py", line 731, in _check_file
    check_astroid_module(ast_node)
  File "/Users/.../pylint/pylint/lint/pylinter.py", line 950, in check_astroid_module
    retval = self._check_astroid_module(
  File "/Users/.../pylint/pylint/lint/pylinter.py", line 1000, in _check_astroid_module
    walker.walk(node)
  File "/Users/.../pylint/pylint/utils/ast_walker.py", line 93, in walk
    self.walk(child)
  File "/Users/.../pylint/pylint/utils/ast_walker.py", line 93, in walk
    self.walk(child)
  File "/Users/.../pylint/pylint/utils/ast_walker.py", line 90, in walk
    callback(astroid)
  File "/Users/.../pylint/pylint/checkers/classes/special_methods_checker.py", line 170, in visit_functiondef
    inferred = _safe_infer_call_result(node, node)
  File "/Users/.../pylint/pylint/checkers/classes/special_methods_checker.py", line 31, in _safe_infer_call_result
    value = next(inferit)
  File "/Users/.../astroid/astroid/nodes/scoped_nodes/scoped_nodes.py", line 1752, in infer_call_result
    yield from returnnode.value.infer(context)
  File "/Users/.../astroid/astroid/nodes/node_ng.py", line 159, in infer
    results = list(self._explicit_inference(self, context, **kwargs))
  File "/Users/.../astroid/astroid/inference_tip.py", line 45, in _inference_tip_cached
    result = _cache[func, node] = list(func(*args, **kwargs))
  File "/Users/.../astroid/astroid/brain/brain_builtin_inference.py", line 948, in _infer_str_format_call
    formatted_string = format_template.format(*pos_values, **keyword_values)
KeyError: 'team_slug'

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "/Users/.../pylint/pylint/lint/pylinter.py", line 688, in _check_files
    self._check_file(get_ast, check_astroid_module, file)
  File "/Users/.../pylint/pylint/lint/pylinter.py", line 733, in _check_file
    raise astroid.AstroidError from e
astroid.exceptions.AstroidError
```
***
cc @DanielNoord in #1602 
found by pylint primer 🚀 
