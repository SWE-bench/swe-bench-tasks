Hey @jaraco, 

I'm making a quick guess as I don't have time to delve deep into the code, but perhaps `from_parent` in `pytest_checkdocs/__init__.py:52` needs to receive `**kw` and pass that on to `super()`?

cc @RonnyPfannschmidt 
That's about it, I wonder if i can make this one a warning for the next releases 
> Perhaps `from_parent` in `pytest_checkdocs/__init__.py:52` needs to receive `**kw` and pass that on to `super()`?

Yes, perhaps. And also pytest-black and pytest-mypy and pytest-flake8 likely and maybe others.
Sounds like I definitely should sort out the signature of the create call and issue a warning 
I tried applying the suggested workaround.

```diff
diff --git a/pytest_checkdocs/__init__.py b/pytest_checkdocs/__init__.py
index 3162319..8469ebe 100644
--- a/pytest_checkdocs/__init__.py
+++ b/pytest_checkdocs/__init__.py
@@ -38,18 +38,18 @@ class Description(str):
 
 
 class CheckdocsItem(pytest.Item, pytest.File):
-    def __init__(self, fspath, parent):
+    def __init__(self, fspath, parent, **kw):
         # ugly hack to add support for fspath parameter
         # Ref pytest-dev/pytest#6928
-        super().__init__(fspath, parent)
+        super().__init__(fspath, parent, **kw)
 
     @classmethod
-    def from_parent(cls, parent, fspath):
+    def from_parent(cls, parent, fspath, **kw):
         """
         Compatibility shim to support
         """
         try:
-            return super().from_parent(parent, fspath=fspath)
+            return super().from_parent(parent, fspath=fspath, **kw)
         except AttributeError:
             # pytest < 5.4
             return cls(fspath, parent)
```

But that only pushed the error down:

```
________________________________________________________________________________ ERROR collecting test session ________________________________________________________________________________
.tox/python/lib/python3.9/site-packages/pluggy/hooks.py:286: in __call__
    return self._hookexec(self, self.get_hookimpls(), kwargs)
.tox/python/lib/python3.9/site-packages/pluggy/manager.py:93: in _hookexec
    return self._inner_hookexec(hook, methods, kwargs)
.tox/python/lib/python3.9/site-packages/pluggy/manager.py:84: in <lambda>
    self._inner_hookexec = lambda hook, methods, kwargs: hook.multicall(
pytest_checkdocs/__init__.py:14: in pytest_collect_file
    CheckdocsItem.from_parent(parent, fspath=path)
pytest_checkdocs/__init__.py:52: in from_parent
    return super().from_parent(parent, fspath=fspath, **kw)
.tox/python/lib/python3.9/site-packages/_pytest/nodes.py:578: in from_parent
    return super().from_parent(parent=parent, fspath=fspath, path=path, **kw)
.tox/python/lib/python3.9/site-packages/_pytest/nodes.py:226: in from_parent
    return cls._create(parent=parent, **kw)
.tox/python/lib/python3.9/site-packages/_pytest/nodes.py:117: in _create
    return super().__call__(*k, **kw)
pytest_checkdocs/__init__.py:44: in __init__
    super().__init__(fspath, parent, **kw)
E   TypeError: __init__() got an unexpected keyword argument 'path'
```

(I tried it with and without adding `**kw` to `__init__`).

I don't understand what these hacks are trying to accomplish, so I'm out of my depth. If someone more familiar with the changes to the interfaces could suggest a fix, I'd be happy to test it and incorporate it. I'm also happy to drop support for older pytest versions (prior to 5.4) if that helps.
@jaraco problem is that the hacks to make the switch from fspath to just pathlib paths where incomplete, and the backward compatibility handling is not yet aware of non keyword parameters

If you pass everything as keywords it should work,

I should however fix that way of invocation
@jaraco the correct fix  is to stop merging items and files, currently python has absolutely no sane support for that inheritance structure, it worked by sheer accident, we should actually just deprecate collecting items and collectors together 

i`m going to add a fitting deprecation warning
The bugs reported here still exist in pytest-black and pytest-flake8, even though they've been fixed in pytest-checkdocs and pytest.mypy. 
@jaraco does it happen against pytest main, or the last release?
Main. I only report the status here because I was too lazy to report it to the downstream projects.

<details>

```
draft $ touch test_something.py
draft $ pip-run -q git+https://github.com/pytest-dev/pytest pytest-black -- -m pytest --black
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-kozax3_l/_pytest/nodes.py:654: PytestWarning: BlackItem is an Item subclass and should not be a collector, however its bases File are collectors.
Please split the Collectors and the Item into separate node types.
Pytest Doc example: https://docs.pytest.org/en/latest/example/nonpython.html
example pull request on a plugin: https://github.com/asmeurer/pytest-flakes/pull/40/
  warnings.warn(
======================================================================== test session starts ========================================================================
platform darwin -- Python 3.10.0, pytest-7.0.0.dev291+g7037a587, pluggy-1.0.0
rootdir: /Users/jaraco/draft
plugins: black-0.3.12
collected 0 items / 1 error                                                                                                                                         

============================================================================== ERRORS ===============================================================================
___________________________________________________________________ ERROR collecting test session ___________________________________________________________________
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-kozax3_l/_pytest/nodes.py:140: in _create
    return super().__call__(*k, **kw)
E   TypeError: BlackItem.__init__() got an unexpected keyword argument 'path'

During handling of the above exception, another exception occurred:
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-kozax3_l/pluggy/_hooks.py:265: in __call__
    return self._hookexec(self.name, self.get_hookimpls(), kwargs, firstresult)
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-kozax3_l/pluggy/_manager.py:80: in _hookexec
    return self._inner_hookexec(hook_name, methods, kwargs, firstresult)
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-kozax3_l/pytest_black.py:27: in pytest_collect_file
    return BlackItem.from_parent(parent, fspath=path)
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-kozax3_l/_pytest/nodes.py:623: in from_parent
    return super().from_parent(parent=parent, fspath=fspath, path=path, **kw)
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-kozax3_l/_pytest/nodes.py:256: in from_parent
    return cls._create(parent=parent, **kw)
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-kozax3_l/_pytest/nodes.py:152: in _create
    return super().__call__(*k, **known_kw)
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-kozax3_l/pytest_black.py:47: in __init__
    super(BlackItem, self).__init__(fspath, parent)
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-kozax3_l/_pytest/nodes.py:672: in __init__
    super().__init__(
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-kozax3_l/_pytest/nodes.py:578: in __init__
    path = _imply_path(type(self), path, fspath=fspath)
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-kozax3_l/_pytest/nodes.py:121: in _imply_path
    assert fspath is not None
E   AssertionError
====================================================================== short test summary info ======================================================================
ERROR  - AssertionError
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Interrupted: 1 error during collection !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
========================================================================= 1 error in 0.09s ==========================================================================
draft $ pip-run -q git+https://github.com/pytest-dev/pytest pytest-flake8 -- -m pytest --flake8
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-dbk66s9v/_pytest/nodes.py:654: PytestWarning: Flake8Item is an Item subclass and should not be a collector, however its bases File are collectors.
Please split the Collectors and the Item into separate node types.
Pytest Doc example: https://docs.pytest.org/en/latest/example/nonpython.html
example pull request on a plugin: https://github.com/asmeurer/pytest-flakes/pull/40/
  warnings.warn(
======================================================================== test session starts ========================================================================
platform darwin -- Python 3.10.0, pytest-7.0.0.dev291+g7037a587, pluggy-1.0.0
rootdir: /Users/jaraco/draft
plugins: flake8-1.0.7
collected 0 items / 1 error                                                                                                                                         

============================================================================== ERRORS ===============================================================================
___________________________________________________________________ ERROR collecting test session ___________________________________________________________________
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-dbk66s9v/_pytest/nodes.py:140: in _create
    return super().__call__(*k, **kw)
E   TypeError: Flake8Item.__init__() got an unexpected keyword argument 'path'

During handling of the above exception, another exception occurred:
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-dbk66s9v/pluggy/_hooks.py:265: in __call__
    return self._hookexec(self.name, self.get_hookimpls(), kwargs, firstresult)
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-dbk66s9v/pluggy/_manager.py:80: in _hookexec
    return self._inner_hookexec(hook_name, methods, kwargs, firstresult)
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-dbk66s9v/pytest_flake8.py:67: in pytest_collect_file
    item = Flake8Item.from_parent(parent, fspath=path)
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-dbk66s9v/_pytest/nodes.py:623: in from_parent
    return super().from_parent(parent=parent, fspath=fspath, path=path, **kw)
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-dbk66s9v/_pytest/nodes.py:256: in from_parent
    return cls._create(parent=parent, **kw)
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-dbk66s9v/_pytest/nodes.py:152: in _create
    return super().__call__(*k, **known_kw)
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-dbk66s9v/pytest_flake8.py:99: in __init__
    super(Flake8Item, self).__init__(fspath, parent)
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-dbk66s9v/_pytest/nodes.py:672: in __init__
    super().__init__(
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-dbk66s9v/_pytest/nodes.py:578: in __init__
    path = _imply_path(type(self), path, fspath=fspath)
/var/folders/c6/v7hnmq453xb6p2dbz1gqc6rr0000gn/T/pip-run-dbk66s9v/_pytest/nodes.py:121: in _imply_path
    assert fspath is not None
E   AssertionError
====================================================================== short test summary info ======================================================================
ERROR  - AssertionError
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Interrupted: 1 error during collection !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
========================================================================= 1 error in 0.10s ==========================================================================
```

</details>
@bluetech Could this be related to the recent change in imply? 
I don't think it's a recent regression. I think the regression happened due to a refactoring in main. I believe the original analysis is still the same. I just came in to report that this incompatibility still exists. I've since filed issues with the downstream projects so they're aware of the impending, intended breakage.
The assert `assert fspath is not None` is not supposed to trigger. I will try to look at this soon.
TL;DR: @RonnyPfannschmidt should look at the diff below and say if we want to go ahead with it to keep this plugins working for a bit longer, or accept the breakage. My opinion is that we should apply it, so the plugins have a chance to fix their code, otherwise they go from working -> broken without deprecation in the middle.

---

The source of the trouble in both pytest-black and pytest-flake8 is that they have their item type inherit from both `pytest.Item` and `pytest.File`. This is already deprecated; I wonder where that pattern came from -- maybe we had bad docs at some point? -- but anyway the entire thing worked only by accident. 

Taking pytest-black as an example, it does

```py
class BlackItem(pytest.Item, pytest.File):
    def __init__(self, fspath, parent):
        super(BlackItem, self).__init__(fspath, parent)
```

the MRO here is

```
<class 'pytest_black.BlackItem'>
<class '_pytest.nodes.Item'>
<class '_pytest.nodes.File'>
<class '_pytest.nodes.FSCollector'>
<class '_pytest.nodes.Collector'>
<class '_pytest.nodes.Node'>
<class 'object'>
```

of interest are the `Item` ctor:

```py
    def __init__(
        self,
        name,
        parent=None,
        config: Optional[Config] = None,
        session: Optional["Session"] = None,
        nodeid: Optional[str] = None,
        **kw,
    ) -> None:
        super().__init__(
            name=name,
            parent=parent,
            config=config,
            session=session,
            nodeid=nodeid,
            **kw,
        )
```

and the `FSCollector` ctor:

```py
class FSCollector(Collector):
    def __init__(
        self,
        fspath: Optional[LEGACY_PATH] = None,
        path_or_parent: Optional[Union[Path, Node]] = None,
        path: Optional[Path] = None,
        name: Optional[str] = None,
        parent: Optional[Node] = None,
        config: Optional[Config] = None,
        session: Optional["Session"] = None,
        nodeid: Optional[str] = None,
    ) -> None:
        if path_or_parent:
            if isinstance(path_or_parent, Node):
                assert parent is None
                parent = cast(FSCollector, path_or_parent)
            elif isinstance(path_or_parent, Path):
                assert path is None
                path = path_or_parent

        path = _imply_path(type(self), path, fspath=fspath)
```

You can see how the `fspath` gets lost here -- it is interpreted as `name`. Before d7b0e172052d855afe444c599330c907cdc53d93 `Item` passed the ctor arguments positionally which made things work mostly by luck/accident. If we want to keep them working for a little bit more while they fix the deprecation warnings, the following diff works:

```diff
diff --git a/src/_pytest/nodes.py b/src/_pytest/nodes.py
index 09bbda0a2..20a3f8739 100644
--- a/src/_pytest/nodes.py
+++ b/src/_pytest/nodes.py
@@ -670,8 +670,8 @@ class Item(Node):
         **kw,
     ) -> None:
         super().__init__(
-            name=name,
-            parent=parent,
+            name,
+            parent,
             config=config,
             session=session,
             nodeid=nodeid,
```
Let's do that and make things nice once the other plugins are fixed, thanks for the investigation 