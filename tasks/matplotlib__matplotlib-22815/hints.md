Hey, I want to try and fix this bug. Will you assign me or should I just start working on it? 
Go for it.
I think this wasn't fully solved for the built-in classes of `matplotlib.colors`. Adding this test to `test_dynamic_norm`:

```python
    # Also test the builtin classes
    norm = mpl.colors.LogNorm(vmin=0.01, vmax=100)

    assert type(pickle.loads(pickle.dumps(norm))) \
        == type(norm)
```

Fails with:

```
E       _pickle.PicklingError: Can't pickle <class 'matplotlib.colors.LogNorm'>: it's not the same object as matplotlib.colors.LogNorm
```
I tried to look into this a bit, and I'm not sure you can use a decorator in this situation to wrap a class definition and keep it picklable at the module-level. I thought you could possibly update the definition in the `globals()` dictionary, but even this doesn't seem to help here. Explicitly calling the decorator as a function, makes things picklable, but then you lose the extra class docstring information that was defined. i.e. here I get information about functools.partial in the docstring.
```python
LogNorm = make_norm_from_scale(functools.partial(scale.LogScale, nonpositive="mask"))
```

I guess I'm somewhat curious if there is some more magic here that can be done to make this actually work... but I'm also wondering how much this is actually gaining over just explicitly defining these named classes in the module (and defining `self._scale` / `self._trf` manually). Note that I'm not saying to remove the function for easily making these norms from scales, but rather just explicitly defining the 4 module-level Norms that use the decorator may be the better route here.
I guess the way out may(?) be to just explicitly check for the condition we want:
```patch
diff --git i/lib/matplotlib/colors.py w/lib/matplotlib/colors.py
index 6d126e6725..95e63a7459 100644
--- i/lib/matplotlib/colors.py
+++ w/lib/matplotlib/colors.py
@@ -1530,6 +1530,10 @@ def _make_norm_from_scale(scale_cls, base_norm_cls, bound_init_signature):
 
     class Norm(base_norm_cls):
         def __reduce__(self):
+            import importlib
+            if type(self) is getattr(importlib.import_module(type(self).__module__),
+                                     type(self).__qualname__):
+                return (_create_empty_object_of_class, (type(self),), self.__dict__)
             return (_picklable_norm_constructor,
                     (scale_cls, base_norm_cls, bound_init_signature),
                     self.__dict__)
@@ -1610,6 +1614,10 @@ def _picklable_norm_constructor(*args):
     return cls.__new__(cls)
 
 
+def _create_empty_object_of_class(cls):
+    return cls.__new__(cls)
+
+
 @make_norm_from_scale(
     scale.FuncScale,
     init=lambda functions, vmin=None, vmax=None, clip=False: None)
```
(then _picklable_norm_constructor can be rewritten to use _create_empty_object_of_class) (also, probably needs some error checking e.g. getattr failing should just fall back to the old path)

At least the following now holds:
```python
from matplotlib.colors import LogNorm; from pickle import *; print(type(loads(dumps(LogNorm()))) is LogNorm)
```

As usual, feel free to pick up the patch.