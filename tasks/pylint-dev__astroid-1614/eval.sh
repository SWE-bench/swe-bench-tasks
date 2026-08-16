#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff aa5a0d92e640ee5f3fa9a8ba3ba058a7b594ca44
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout aa5a0d92e640ee5f3fa9a8ba3ba058a7b594ca44 tests/unittest_brain_builtin.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/unittest_brain_builtin.py b/tests/unittest_brain_builtin.py
--- a/tests/unittest_brain_builtin.py
+++ b/tests/unittest_brain_builtin.py
@@ -93,6 +93,9 @@ def test_string_format(self, format_string: str) -> None:
             "My name is {}, I'm {}".format(Unknown, 12)
             """,
             """"I am {}".format()""",
+            """
+            "My name is {fname}, I'm {age}".format(fsname = "Daniel", age = 12)
+            """,
         ],
     )
     def test_string_format_uninferable(self, format_string: str) -> None:

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/unittest_brain_builtin.py
: '>>>>> End Test Output'
git checkout aa5a0d92e640ee5f3fa9a8ba3ba058a7b594ca44 tests/unittest_brain_builtin.py
