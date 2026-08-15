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