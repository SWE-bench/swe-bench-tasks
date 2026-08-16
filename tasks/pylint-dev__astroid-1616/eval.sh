#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 6280a758733434cba32b719519908314a5c2955b
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 6280a758733434cba32b719519908314a5c2955b tests/unittest_brain_builtin.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/unittest_brain_builtin.py b/tests/unittest_brain_builtin.py
--- a/tests/unittest_brain_builtin.py
+++ b/tests/unittest_brain_builtin.py
@@ -66,6 +66,13 @@ class TestStringNodes:
         """,
                 id="mixed-indexes-from-mixed",
             ),
+            pytest.param(
+                """
+        string = "My name is {}, I'm {}"
+        string.format("Daniel", 12)
+        """,
+                id="empty-indexes-on-variable",
+            ),
         ],
     )
     def test_string_format(self, format_string: str) -> None:

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/unittest_brain_builtin.py
: '>>>>> End Test Output'
git checkout 6280a758733434cba32b719519908314a5c2955b tests/unittest_brain_builtin.py
