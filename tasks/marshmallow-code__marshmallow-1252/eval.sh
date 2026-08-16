#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff b063a103ae5222a5953cd7453a1eb0d161dc5b52
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e '.[dev]'
git checkout b063a103ae5222a5953cd7453a1eb0d161dc5b52 tests/test_utils.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_utils.py b/tests/test_utils.py
--- a/tests/test_utils.py
+++ b/tests/test_utils.py
@@ -200,6 +200,15 @@ def test_from_iso_datetime(use_dateutil, timezone):
     assert type(result) == dt.datetime
     assert_datetime_equal(result, d)
 
+    # Test with 3-digit only microseconds
+    # Regression test for https://github.com/marshmallow-code/marshmallow/issues/1251
+    d = dt.datetime.now(tz=timezone).replace(microsecond=123000)
+    formatted = d.isoformat()
+    formatted = formatted[:23] + formatted[26:]
+    result = utils.from_iso(formatted, use_dateutil=use_dateutil)
+    assert type(result) == dt.datetime
+    assert_datetime_equal(result, d)
+
 def test_from_iso_with_tz():
     d = central.localize(dt.datetime.now())
     formatted = d.isoformat()

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/test_utils.py
: '>>>>> End Test Output'
git checkout b063a103ae5222a5953cd7453a1eb0d161dc5b52 tests/test_utils.py
