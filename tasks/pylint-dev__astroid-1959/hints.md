Thank you for the investigation @The-Compiler ! I'm going to revert the offending commit seeing it's only a cleanup. Let's do something more elegant later on if required.
The commit you linked is from a fork, so I tried to reproduce locally to bisect on pylint main repo but I cannot
```
pip3 install PyQt5
Collecting PyQt5
 Collecting PyQt5-sip<13,>=12.11
Collecting PyQt5-Qt5>=5.15.0
Installing collected packages: PyQt5-Qt5, PyQt5-sip, PyQt5
Successfully installed PyQt5-5.15.7 PyQt5-Qt5-5.15.2 PyQt5-sip-12.11.0
(venv) fix-crash-regression-2.13.2: pylint --extension-pkg-whitelist=PyQt5 x.py 
************* Module x
x.py:1:0: W0611: Unused QtWidgets imported from PyQt5 (unused-import)
---------------------------------------------------------------------

Your code has been rated at 0.00/10 (previous run: -50.00/10, +50.00)
```
Could you provide your other dependencies maybe ?

> The commit you linked is from a fork, so I tried to reproduce locally to bisect on pylint main repo but I cannot

The main astroid repo bisects to the merge of #1885 (f26dbe419ac15a87ed65e9b55ed15d3d8100b608) - that was a squash merge, 974f26f75eb3eccb4bcd8ea143901baf60a685ff is my guess at what in the PR is the problem.

> Could you provide your other dependencies maybe ?

Nothing else really:

```
─[florian@aragog]──[~/tmp/pylintbug]──[23-01-10]──[12:35]────┄
$ python3 --version
Python 3.10.8

─[florian@aragog]──[~/tmp/pylintbug]──[23-01-10]──[12:35]────┄
$ python3 -m venv .venv
python3 -m venv .venv  2.87s user 0.26s system 98% cpu 3.170 total

─[florian@aragog]──[~/tmp/pylintbug]──[23-01-10]──[12:35]────┄
$ .venv/bin/pip install pylint PyQt5
Collecting pylint
  Using cached pylint-2.15.10-py3-none-any.whl (509 kB)
Collecting PyQt5
  Using cached PyQt5-5.15.7-cp37-abi3-manylinux1_x86_64.whl (8.4 MB)
Collecting tomli>=1.1.0
  Using cached tomli-2.0.1-py3-none-any.whl (12 kB)
Collecting tomlkit>=0.10.1
  Using cached tomlkit-0.11.6-py3-none-any.whl (35 kB)
Collecting platformdirs>=2.2.0
  Using cached platformdirs-2.6.2-py3-none-any.whl (14 kB)
Collecting mccabe<0.8,>=0.6
  Using cached mccabe-0.7.0-py2.py3-none-any.whl (7.3 kB)
Collecting dill>=0.2
  Using cached dill-0.3.6-py3-none-any.whl (110 kB)
Collecting astroid<=2.14.0-dev0,>=2.12.13
  Using cached astroid-2.13.2-py3-none-any.whl (272 kB)
Collecting isort<6,>=4.2.5
  Using cached isort-5.11.4-py3-none-any.whl (104 kB)
Collecting PyQt5-Qt5>=5.15.0
  Using cached PyQt5_Qt5-5.15.2-py3-none-manylinux2014_x86_64.whl (59.9 MB)
Collecting PyQt5-sip<13,>=12.11
  Using cached PyQt5_sip-12.11.0-cp310-cp310-manylinux1_x86_64.whl (359 kB)
Collecting lazy-object-proxy>=1.4.0
  Using cached lazy_object_proxy-1.9.0-cp310-cp310-manylinux_2_5_x86_64.manylinux1_x86_64.manylinux_2_17_x86_64.manylinux2014_x86_64.whl (63 kB)
Collecting wrapt<2,>=1.11
  Using cached wrapt-1.14.1-cp310-cp310-manylinux_2_5_x86_64.manylinux1_x86_64.manylinux_2_17_x86_64.manylinux2014_x86_64.whl (77 kB)
Collecting typing-extensions>=4.0.0
  Using cached typing_extensions-4.4.0-py3-none-any.whl (26 kB)
Installing collected packages: PyQt5-Qt5, wrapt, typing-extensions, tomlkit, tomli, PyQt5-sip, platformdirs, mccabe, lazy-object-proxy, isort, dill, PyQt5, astroid, pylint
Successfully installed PyQt5-5.15.7 PyQt5-Qt5-5.15.2 PyQt5-sip-12.11.0 astroid-2.13.2 dill-0.3.6 isort-5.11.4 lazy-object-proxy-1.9.0 mccabe-0.7.0 platformdirs-2.6.2 pylint-2.15.10 tomli-2.0.1 tomlkit-0.11.6 typing-extensions-4.4.0 wrapt-1.14.1

[notice] A new release of pip available: 22.2.2 -> 22.3.1
[notice] To update, run: python3 -m pip install --upgrade pip
.venv/bin/pip install pylint PyQt5  3.18s user 0.57s system 74% cpu 5.004 total

─[florian@aragog]──[~/tmp/pylintbug]──[23-01-10]──[12:35]────┄
$ cat x.py
from PyQt5 import QtWidgets

─[florian@aragog]──[~/tmp/pylintbug]──[23-01-10]──[12:35]────┄
$ .venv/bin/pylint --extension-pkg-whitelist=PyQt5 x.py 
************* Module x
x.py:1:0: C0114: Missing module docstring (missing-module-docstring)
Exception on node <ImportFrom l.1 at 0x7fa1f6e37d90> in file '/home/florian/tmp/pylintbug/x.py'
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
x.py:1:0: F0002: x.py: Fatal error while checking 'x.py'. Please open an issue in our bug tracker so we address this. There is a pre-filled template that you can use in '/home/florian/.cache/pylint/pylint-crash-2023-01-10-12-36-04.txt'. (astroid-error)

------------------------------------------------------------------
Your code has been rated at 0.00/10 (previous run: 0.00/10, +0.00)
```
