#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff e884df2d00473a6ab166cb92a68d0b500a89d159
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout e884df2d00473a6ab166cb92a68d0b500a89d159 test/cli/commands_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/cli/commands_test.py b/test/cli/commands_test.py
--- a/test/cli/commands_test.py
+++ b/test/cli/commands_test.py
@@ -251,6 +251,14 @@ def test__cli__command_lint_stdin(command):
     invoke_assert_code(args=[lint, ("--dialect=ansi",) + command], cli_input=sql)
 
 
+def test__cli__command_lint_empty_stdin():
+    """Check linting an empty file raises no exceptions.
+
+    https://github.com/sqlfluff/sqlfluff/issues/4807
+    """
+    invoke_assert_code(args=[lint, ("-d", "ansi", "-")], cli_input="")
+
+
 def test__cli__command_render_stdin():
     """Check render on a simple script using stdin."""
     with open("test/fixtures/cli/passing_a.sql") as test_file:

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/cli/commands_test.py
: '>>>>> End Test Output'
git checkout e884df2d00473a6ab166cb92a68d0b500a89d159 test/cli/commands_test.py
