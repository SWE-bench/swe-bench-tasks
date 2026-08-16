#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 344454c8ee25d41a4ce12980bc85ba604b7835dd
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 344454c8ee25d41a4ce12980bc85ba604b7835dd tests/unittest_brain_builtin.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/unittest_brain_builtin.py b/tests/unittest_brain_builtin.py
--- a/tests/unittest_brain_builtin.py
+++ b/tests/unittest_brain_builtin.py
@@ -109,6 +109,10 @@ def test_string_format(self, format_string: str) -> None:
             """
             "My hex format is {:4x}".format('1')
             """,
+            """
+            daniel_age = 12
+            "My name is {0.name}".format(daniel_age)
+            """,
         ],
     )
     def test_string_format_uninferable(self, format_string: str) -> None:

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/unittest_brain_builtin.py
: '>>>>> End Test Output'
git checkout 344454c8ee25d41a4ce12980bc85ba604b7835dd tests/unittest_brain_builtin.py
