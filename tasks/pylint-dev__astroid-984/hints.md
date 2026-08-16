Some notes:

- The `ModuleNotFoundError` exception is thrown by `importlib.util.find_spec`. Before python 3.7 this was an `AttributeError`
- `modutils.is_relative()` is the call-site for the `find_spec` call
- It seems that `is_ralative()` is trying to find a parent mod-spec for the anchor `from_file` parameter so that it can check to see if the `modname` is contained by it
- Neither `is_relative` nor its tests, explicitly handle on-disk paths (that is, paths for which `os.path.exists()` returns `True`) vs virtual-paths (`exists() == False`). The seems to be important to `find_spec` which raises if the package's `__path__` attribute isn't found (which it won't be for virtual paths).
- The existing unit tests for `is_realtive()` use a range of modules to check against a set of module paths via `__path__[0]`. Somehow these pass and it is not clear why/how

One workaround fix, that feels like a hack until I understand the problem better, is for `is_relative()` to handle the `ModuleNotFoundError`/`AttributeError` exceptions and them as signifying that the `parent_spec` is being not-yet found. However, that requires that the loop-logic is fixed for linux-like systems, otherwise you end up in an infinite loop with `len(file_path)>0` always being true for `/` and `file_path = os.path.dirname('/')` always returning `/`.

I have written some new unit tests for this issue and extended the existing ones, but there is some fundamental logic underpinning the use of `importlib.util.find_spec` that I am not smart enough to understand. For example, why do the existing unit-tests not all use the same `modname` parameter? Is it to work around the import caching in `sys.modules`? Should we take that into account?

My unit tests look at both virtual and ondisk paths (because of the `if not os.path.isdir(from_file):` line in `is_realtive()`, and the docs for `find_spec`). They also look at both absolute and relative paths explicitly. Finally, they also use system modules and assert that they are already in the import cache.

.. and I thought this fix was going to be easy.
@doublethefish thanks for your report and investigation.
I can reproduce it and i confirm that #857 is the origin of the issue.
It seems like this happens if an import inside a package which is at least two levels deep is processed.
For example, trying to run ``pyreverse`` on ``pylint`` itself will crash as soon as the import statements in checker modules in ``pylint.checkers.refactoring`` are processed.
``importlib.util.find_spec(name, from_file)`` is called with ``name`` = ``checkers.refactoring``. 
``find_spec`` will then split this up and try to import ``checkers``, which fails because the path to _inside_ the ``pylint`` package (i.e. ``pylint/pylint`` from the repo root) is normally not in the Pythonpath.