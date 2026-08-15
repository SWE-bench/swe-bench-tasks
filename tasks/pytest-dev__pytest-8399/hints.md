This issue also seems to affect xunit style test-classes:
```
import unittest

class Tests(unittest.TestCase):
    @classmethod
    def setup_class(cls):
        pass

    def test_1(self):
        pass
```
```
~$  pytest --fixtures
...
xunit_setup_class_fixture_Tests [class scope]
    /home/ubuntu/src/Platform/.venv/lib/python3.6/site-packages/_pytest/python.py:803: no docstring available
```

Thanks @atzannes!

This was probably introduced in https://github.com/pytest-dev/pytest/pull/7990, https://github.com/pytest-dev/pytest/pull/7931, and https://github.com/pytest-dev/pytest/pull/7929.

The fix should be simple: add a `_` in each of the generated fixtures names. 

I did a quick change locally, and it fixes that first case reported:

```diff
diff --git a/src/_pytest/unittest.py b/src/_pytest/unittest.py
index 719eb4e88..3f88d7a9e 100644
--- a/src/_pytest/unittest.py
+++ b/src/_pytest/unittest.py
@@ -144,7 +144,7 @@ def _make_xunit_fixture(
         scope=scope,
         autouse=True,
         # Use a unique name to speed up lookup.
-        name=f"unittest_{setup_name}_fixture_{obj.__qualname__}",
+        name=f"_unittest_{setup_name}_fixture_{obj.__qualname__}",
     )
     def fixture(self, request: FixtureRequest) -> Generator[None, None, None]:
         if _is_skipped(self):
``` 

Of course a similar change needs to be applied to the other generated fixtures. 

I'm out of time right now to write a proper PR, but I'm leaving this in case someone wants to step up. 👍 
I can take a cut at this