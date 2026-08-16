Cython module with import triggers deep introspection for pandas, raises unhandled FutureWarning
This is a somewhat complicated situation to reproduce, but basically `pandas` throws `FutureWarning`s for certain attributes, and when you import it into a Cython module (triggering astroid's deep module inspection), these future warnings are not handled by astroid and bubble up as `AstroidError`s through to pylint. Here is a full repro:


### Cython module `pyx.pyx`

```python
# distutils: language = c++
import pandas as pd

cdef class Test:
    def __cinit__(self):
        ...
```


### Python module `test.py`

```python
import pyx

pyx.Test()
```



### Commands
```
cythonize -a -i pyx.pyx
pylint --extension-pkg-allow-list=pyx,pandas test.py
```


### Exception
```
Exception on node <Import l.1 at 0x106b23ca0> in file '/Users/timkpaine/Programs/projects/other/astroid/test.py'
Traceback (most recent call last):
  File "/opt/homebrew/lib/python3.9/site-packages/pylint/checkers/imports.py", line 765, in _get_imported_module
    return importnode.do_import_module(modname)
  File "/opt/homebrew/lib/python3.9/site-packages/astroid/mixins.py", line 102, in do_import_module
    return mymodule.import_module(
  File "/opt/homebrew/lib/python3.9/site-packages/astroid/nodes/scoped_nodes/scoped_nodes.py", line 527, in import_module
    return AstroidManager().ast_from_module_name(absmodname)
  File "/opt/homebrew/lib/python3.9/site-packages/astroid/manager.py", line 168, in ast_from_module_name
    return self.ast_from_module(module, modname)
  File "/opt/homebrew/lib/python3.9/site-packages/astroid/manager.py", line 265, in ast_from_module
    return AstroidBuilder(self).module_build(module, modname)
  File "/opt/homebrew/lib/python3.9/site-packages/astroid/builder.py", line 91, in module_build
    node = self.inspect_build(module, modname=modname, path=path)
  File "/opt/homebrew/lib/python3.9/site-packages/astroid/raw_building.py", line 311, in inspect_build
    self.object_build(node, module)
  File "/opt/homebrew/lib/python3.9/site-packages/astroid/raw_building.py", line 367, in object_build
    self.object_build(module, member)
  File "/opt/homebrew/lib/python3.9/site-packages/astroid/raw_building.py", line 325, in object_build
    member = getattr(obj, name)
  File "/opt/homebrew/lib/python3.9/site-packages/pandas/__init__.py", line 198, in __getattr__
    warnings.warn(
FutureWarning: pandas.Float64Index is deprecated and will be removed from pandas in a future version. Use pandas.Index with the appropriate dtype instead.

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "/opt/homebrew/lib/python3.9/site-packages/pylint/utils/ast_walker.py", line 90, in walk
    callback(astroid)
  File "/opt/homebrew/lib/python3.9/site-packages/pylint/checkers/imports.py", line 472, in visit_import
    imported_module = self._get_imported_module(node, name)
  File "/opt/homebrew/lib/python3.9/site-packages/pylint/checkers/imports.py", line 788, in _get_imported_module
    raise astroid.AstroidError from e
astroid.exceptions.AstroidError
************* Module test
test.py:1:0: F0002: test.py: Fatal error while checking 'test.py'. Please open an issue in our bug tracker so we address this. There is a pre-filled template that you can use in '/Users/timkpaine/Library/Caches/pylint/pylint-crash-2022-07-19-17.txt'. (astroid-error)
```




### Standalone (Non Cython) repro for convenience

```python
import types
import pandas as pd
from astroid.builder import AstroidBuilder


m = types.ModuleType("test")
m.pd = pd

AstroidBuilder().module_build(m, "test")
```


xref: https://github.com/PyCQA/pylint/issues/7205
xref: https://github.com/PyCQA/astroid/pull/1719
