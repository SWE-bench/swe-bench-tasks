ImportError: cannot import name 'Statement' from 'astroid.node_classes' 
### Steps to reproduce

1. run pylint <some_file>


### Current behavior

```python
exception: Traceback (most recent call last):
  File "/usr/lib/python3.9/runpy.py", line 197, in _run_module_as_main
    return _run_code(code, main_globals, None,
  File "/usr/lib/python3.9/runpy.py", line 87, in _run_code
    exec(code, run_globals)
  File "/home/user/folder/check_mk/.venv/lib/python3.9/site-packages/pylint/__main__.py", line 9, in <module>
    pylint.run_pylint()
  File "/home/user/folder/check_mk/.venv/lib/python3.9/site-packages/pylint/__init__.py", line 24, in run_pylint
    PylintRun(sys.argv[1:])
  File "/home/user/folder/check_mk/.venv/lib/python3.9/site-packages/pylint/lint/run.py", line 331, in __init__
    linter.load_plugin_modules(plugins)
  File "/home/user/folder/check_mk/.venv/lib/python3.9/site-packages/pylint/lint/pylinter.py", line 551, in load_plugin_modules
    module = astroid.modutils.load_module_from_name(modname)
  File "/home/user/folder/check_mk/.venv/lib/python3.9/site-packages/astroid/modutils.py", line 218, in load_module_from_name
    return importlib.import_module(dotted_name)
  File "/usr/lib/python3.9/importlib/__init__.py", line 127, in import_module
    return _bootstrap._gcd_import(name[level:], package, level)
  File "<frozen importlib._bootstrap>", line 1030, in _gcd_import
  File "<frozen importlib._bootstrap>", line 1007, in _find_and_load
  File "<frozen importlib._bootstrap>", line 986, in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 680, in _load_unlocked
  File "<frozen importlib._bootstrap_external>", line 855, in exec_module
  File "<frozen importlib._bootstrap>", line 228, in _call_with_frames_removed
  File "/home/user/folder/check_mk/tests/testlib/pylint_checker_cmk_module_layers.py", line 14, in <module>
    from astroid.node_classes import Import, ImportFrom, Statement  # type: ignore[import]
ImportError: cannot import name 'Statement' from 'astroid.node_classes' (/home/user/folder/check_mk/.venv/lib/python3.9/site-packages/astroid/node_classes.py)
```

### Expected behavior
No exception

### `python -c "from astroid import __pkginfo__; print(__pkginfo__.version)"` output
2.7.3
pylint 2.10.2
astroid 2.7.3
Python 3.9.5 (default, May 11 2021, 08:20:37) 
