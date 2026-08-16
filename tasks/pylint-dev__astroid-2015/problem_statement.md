Replace modutils.is_standard_module() logic with sys.stdlib_module_names

This extends from the conversation in https://github.com/PyCQA/pylint/pull/8190.

The logic in `modutils.is_standard_module()` should largely be able to be replaced with [sys.stdlib_module_names](https://docs.python.org/3/library/sys.html#sys.stdlib_module_names), which was introduced in 3.10. The advantages are it will be faster (no imports, no filesystem traversal), it's not dependent on the local environment,  and it's maintained upstream, generated from source. For the referenced PR, I backported the generating code in CPython to generate sets for a shim to support 3.7 - 3.9.

I started working on a PR for Astroid, but it seems `modutils.is_standard_module()` actually does two different things depending on how it's called.
1. If no path is specified, it tries to determine if a module is part of the standard library (or a builtin, or compiled in) by inspecting the path of module after importing it.
2. If a path is specified, it does the same logic, but ultimately is determining if the module is in the path specified.

For the second case, I could only find one case in the wild, in pyreverse.

https://github.com/PyCQA/pylint/blob/5bc4cd9a4b4c240227a41786823a6f226864dc4b/pylint/pyreverse/inspector.py#L308

These seem like different behaviors to me. I'm unsure how to proceed with PR. Here are some options I've considered.

- Option 1:
  - Introduce a new function, basically a wrapper for sys.stdlib_module_names and the shim
  - Old behavior is preserved
  - Advantage of a function, even though it's very simple, is it provides a space to add overriding logic if needed down the road
   
- Option 2:
   - Only introduce the shim, so the code is in a common place for Astroid and Pylint
   - Can be dropped with 3.9
   - Old behavior is preserved

- Option 3:
  - Fall back to old behavior if a path is given, check sys.stdlib_module_names otherwise

- Option 4:
  - Deprecate `is_standard_module()`
  - Introduce new functions more specific to how they are used

- Option 5:
  - Do Nothing

I'm sure there are more options, but this is what comes to mind now. Would appreciate your thoughts and ideas.

