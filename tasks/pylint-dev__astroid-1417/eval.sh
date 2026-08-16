#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff da745538c7236028a22cdf0405f6829fcf6886bc
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout da745538c7236028a22cdf0405f6829fcf6886bc tests/unittest_decorators.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/unittest_decorators.py b/tests/unittest_decorators.py
--- a/tests/unittest_decorators.py
+++ b/tests/unittest_decorators.py
@@ -1,7 +1,8 @@
 import pytest
 from _pytest.recwarn import WarningsRecorder
 
-from astroid.decorators import deprecate_default_argument_values
+from astroid.const import PY38_PLUS
+from astroid.decorators import cachedproperty, deprecate_default_argument_values
 
 
 class SomeClass:
@@ -97,3 +98,18 @@ def test_deprecated_default_argument_values_ok(recwarn: WarningsRecorder) -> Non
         instance = SomeClass(name="some_name")
         instance.func(name="", var=42)
         assert len(recwarn) == 0
+
+
+@pytest.mark.skipif(not PY38_PLUS, reason="Requires Python 3.8 or higher")
+def test_deprecation_warning_on_cachedproperty() -> None:
+    """Check the DeprecationWarning on cachedproperty."""
+
+    with pytest.warns(DeprecationWarning) as records:
+
+        class MyClass:  # pylint: disable=unused-variable
+            @cachedproperty
+            def my_property(self):
+                return 1
+
+        assert len(records) == 1
+        assert "functools.cached_property" in records[0].message.args[0]

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/unittest_decorators.py
: '>>>>> End Test Output'
git checkout da745538c7236028a22cdf0405f6829fcf6886bc tests/unittest_decorators.py
