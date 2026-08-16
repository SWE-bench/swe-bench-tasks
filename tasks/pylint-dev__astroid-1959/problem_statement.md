v2.13.x regression: Crash when inspecting `PyQt5.QtWidgets` due to `RuntimeError` during `hasattr`
### Steps to reproduce

Install PyQt5, run `pylint --extension-pkg-whitelist=PyQt5 x.py` over a file containing `from PyQt5 import QtWidgets`

### Current behavior

With astroid 2.12.13 and pylint 2.15.10, this works fine. With astroid 2.13.2, this happens:

```pytb
Exception on node <ImportFrom l.1 at 0x7fc5a3c47d00> in file '/home/florian/tmp/pylintbug/x.py'
Traceback (most recent call last):
  File "/home/florian/tmp/pylintbug/.venv/lib/python3.10/site-packages/pylint/utils/ast_walker.py", line 90, in walk
    callback(astroid)
  File "/home/florian/tmp/pylintbug/.venv/lib/python3.10/site-packages/pylint/checkers/variables.py", line 1726, in visit_importfrom
    self._check_module_attrs(node, module, name.split("."))
  File "/home/florian/tmp/pylintbug/.venv/lib/python3.10/site-packages/pylint/checkers/variables.py", line 2701, in _check_module_attrs
    module = next(module.getattr(name)[0].infer())
  File "/home/florian/tmp/pylintbug/.venv/lib/python3.10/site-packages/astroid/nodes/scoped_nodes/scoped_nodes.py", line 412, in getattr
    result = [self.import_module(name, relative_only=True)]
  File "/home/florian/tmp/pylintbug/.venv/lib/python3.10/site-packages/astroid/nodes/scoped_nodes/scoped_nodes.py", line 527, in import_module
    return AstroidManager().ast_from_module_name(
  File "/home/florian/tmp/pylintbug/.venv/lib/python3.10/site-packages/astroid/manager.py", line 205, in ast_from_module_name
    return self.ast_from_module(named_module, modname)
  File "/home/florian/tmp/pylintbug/.venv/lib/python3.10/site-packages/astroid/manager.py", line 312, in ast_from_module
    return AstroidBuilder(self).module_build(module, modname)
  File "/home/florian/tmp/pylintbug/.venv/lib/python3.10/site-packages/astroid/builder.py", line 101, in module_build
    node = self.inspect_build(module, modname=modname, path=path)
  File "/home/florian/tmp/pylintbug/.venv/lib/python3.10/site-packages/astroid/raw_building.py", line 366, in inspect_build
    self.object_build(node, module)
  File "/home/florian/tmp/pylintbug/.venv/lib/python3.10/site-packages/astroid/raw_building.py", line 422, in object_build
    elif hasattr(member, "__all__"):
RuntimeError: wrapped C/C++ object of type QApplication has been deleted
x.py:1:0: F0002: x.py: Fatal error while checking 'x.py'. Please open an issue in our bug tracker so we address this. There is a pre-filled template that you can use in '/home/florian/.cache/pylint/pylint-crash-2023-01-10-11-06-17.txt'. (astroid-error)
```

It looks like it happens when `member` is `QtWidgets.qApp`, which is a kind of "magic" object referring to the QApplication singleton. Since none exists, it looks like PyQt doesn't like trying to access an attribute on that.

Bisected to:

- #1885 

It looks like 974f26f75eb3eccb4bcd8ea143901baf60a685ff is the exact culprit.

cc @nickdrozd 

(took the freedom to add appropriate labels already, hope that's fine)

