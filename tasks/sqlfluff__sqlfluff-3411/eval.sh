#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff e60272a859e37e335088ae79a7ad59ea771545a1
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout e60272a859e37e335088ae79a7ad59ea771545a1 test/cli/commands_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/cli/commands_test.py b/test/cli/commands_test.py
--- a/test/cli/commands_test.py
+++ b/test/cli/commands_test.py
@@ -100,6 +100,53 @@ def test__cli__command_dialect():
     )
 
 
+def test__cli__command_parse_error_dialect_explicit_warning():
+    """Check parsing error raises the right warning."""
+    # For any parsing error there should be a non-zero exit code
+    # and a human-readable warning should be dislayed.
+    # Dialect specified as commandline option.
+    result = invoke_assert_code(
+        ret_code=66,
+        args=[
+            parse,
+            [
+                "-n",
+                "--dialect",
+                "postgres",
+                "test/fixtures/cli/fail_many.sql",
+            ],
+        ],
+    )
+    assert (
+        "WARNING: Parsing errors found and dialect is set to 'postgres'. "
+        "Have you configured your dialect correctly?" in result.stdout
+    )
+
+
+def test__cli__command_parse_error_dialect_implicit_warning():
+    """Check parsing error raises the right warning."""
+    # For any parsing error there should be a non-zero exit code
+    # and a human-readable warning should be dislayed.
+    # Dialect specified in .sqlfluff config.
+    result = invoke_assert_code(
+        ret_code=66,
+        args=[
+            # Config sets dialect to tsql
+            parse,
+            [
+                "-n",
+                "--config",
+                "test/fixtures/cli/extra_configs/.sqlfluff",
+                "test/fixtures/cli/fail_many.sql",
+            ],
+        ],
+    )
+    assert (
+        "WARNING: Parsing errors found and dialect is set to 'tsql'. "
+        "Have you configured your dialect correctly?" in result.stdout
+    )
+
+
 def test__cli__command_dialect_legacy():
     """Check the script raises the right exception on a legacy dialect."""
     result = invoke_assert_code(

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/cli/commands_test.py
: '>>>>> End Test Output'
git checkout e60272a859e37e335088ae79a7ad59ea771545a1 test/cli/commands_test.py
