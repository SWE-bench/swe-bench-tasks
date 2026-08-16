Pyreverse regression after #857 (astroid 2.5)
### Steps to reproduce
1. Checkout pylint's source (which contains pyreverse)
1. cd `<pylint checkout>` 
2. Run `source .tox/py39/bin/activate` or similar (you may need to run a tox session first)
3. Ensure you have `astroid` ac2b173bc8acd2d08f6b6ffe29dd8cda0b2c8814 or later
4. Ensure you have installed `astroid` (`python3 -m pip install -e <path-to-astroid>`) as dependencies may be different
4. Run `pyreverse --output png --project test tests/data`

### Current behaviour
A `ModuleNotFoundError` exception is raised.

```
$ pyreverse --output png --project test tests/data
parsing tests/data/__init__.py...
parsing /opt/contrib/pylint/pylint/tests/data/suppliermodule_test.py...
parsing /opt/contrib/pylint/pylint/tests/data/__init__.py...
parsing /opt/contrib/pylint/pylint/tests/data/clientmodule_test.py...
Traceback (most recent call last):
  File "/opt/contrib/pylint/pylint/.tox/py39/bin/pyreverse", line 8, in <module>
    sys.exit(run_pyreverse())
  File "/opt/contrib/pylint/pylint/.tox/py39/lib/python3.9/site-packages/pylint/__init__.py", line 39, in run_pyreverse
    PyreverseRun(sys.argv[1:])
  File "/opt/contrib/pylint/pylint/.tox/py39/lib/python3.9/site-packages/pylint/pyreverse/main.py", line 201, in __init__
    sys.exit(self.run(args))
  File "/opt/contrib/pylint/pylint/.tox/py39/lib/python3.9/site-packages/pylint/pyreverse/main.py", line 219, in run
    diadefs = handler.get_diadefs(project, linker)
  File "/opt/contrib/pylint/pylint/.tox/py39/lib/python3.9/site-packages/pylint/pyreverse/diadefslib.py", line 236, in get_diadefs
    diagrams = DefaultDiadefGenerator(linker, self).visit(project)
  File "/opt/contrib/pylint/pylint/.tox/py39/lib/python3.9/site-packages/pylint/pyreverse/utils.py", line 210, in visit
    self.visit(local_node)
  File "/opt/contrib/pylint/pylint/.tox/py39/lib/python3.9/site-packages/pylint/pyreverse/utils.py", line 207, in visit
    methods[0](node)
  File "/opt/contrib/pylint/pylint/.tox/py39/lib/python3.9/site-packages/pylint/pyreverse/diadefslib.py", line 162, in visit_module
    self.linker.visit(node)
  File "/opt/contrib/pylint/pylint/.tox/py39/lib/python3.9/site-packages/pylint/pyreverse/utils.py", line 210, in visit
    self.visit(local_node)
  File "/opt/contrib/pylint/pylint/.tox/py39/lib/python3.9/site-packages/pylint/pyreverse/utils.py", line 207, in visit
    methods[0](node)
  File "/opt/contrib/pylint/pylint/.tox/py39/lib/python3.9/site-packages/pylint/pyreverse/inspector.py", line 257, in visit_importfrom
    relative = astroid.modutils.is_relative(basename, context_file)
  File "/opt/contrib/pylint/astroid/astroid/modutils.py", line 581, in is_relative
    parent_spec = importlib.util.find_spec(name, from_file)
  File "/usr/local/Cellar/python@3.9/3.9.2_4/Frameworks/Python.framework/Versions/3.9/lib/python3.9/importlib/util.py", line 94, in find_spec
    parent = __import__(parent_name, fromlist=['__path__'])
ModuleNotFoundError: No module named 'pylint.tests'
```

### Expected behaviour
No exception should be raised. Prior to #857 no exception was raised.

```
$ pyreverse --output png --project test tests/data
parsing tests/data/__init__.py...
parsing /opt/contributing/pylint/tests/data/suppliermodule_test.py...
parsing /opt/contributing/pylint/tests/data/__init__.py...
parsing /opt/contributing/pylint/tests/data/clientmodule_test.py...
```

### ``python -c "from astroid import __pkginfo__; print(__pkginfo__.version)"`` output
`2.6.0-dev0` (cab9b08737ed7aad2a08ce90718c67155fa5c4a0)

