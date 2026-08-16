#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff dc59c2a5672aacedaf91f0e6129b467eefad331b
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout dc59c2a5672aacedaf91f0e6129b467eefad331b test/cli/commands_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/cli/commands_test.py b/test/cli/commands_test.py
--- a/test/cli/commands_test.py
+++ b/test/cli/commands_test.py
@@ -1775,6 +1775,46 @@ def test_cli_lint_enabled_progress_bar_multiple_files(
         assert r"\rrule L001:" in raw_output
         assert r"\rrule L049:" in raw_output
 
+    def test_cli_fix_disabled_progress_bar(
+        self, mock_disable_progress_bar: MagicMock
+    ) -> None:
+        """When progress bar is disabled, nothing should be printed into output."""
+        result = invoke_assert_code(
+            args=[
+                fix,
+                [
+                    "--disable-progress-bar",
+                    "test/fixtures/linter/passing.sql",
+                ],
+            ],
+        )
+        raw_output = repr(result.output)
+
+        assert (
+            "DeprecationWarning: The option '--disable_progress_bar' is deprecated, "
+            "use '--disable-progress-bar'"
+        ) not in raw_output
+
+    def test_cli_fix_disabled_progress_bar_deprecated_option(
+        self, mock_disable_progress_bar: MagicMock
+    ) -> None:
+        """Same as above but checks additionally if deprecation warning is printed."""
+        result = invoke_assert_code(
+            args=[
+                fix,
+                [
+                    "--disable_progress_bar",
+                    "test/fixtures/linter/passing.sql",
+                ],
+            ],
+        )
+        raw_output = repr(result.output)
+
+        assert (
+            "DeprecationWarning: The option '--disable_progress_bar' is deprecated, "
+            "use '--disable-progress-bar'"
+        ) in raw_output
+
 
 multiple_expected_output = """==== finding fixable violations ====
 == [test/fixtures/linter/multiple_sql_errors.sql] FAIL

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/cli/commands_test.py
: '>>>>> End Test Output'
git checkout dc59c2a5672aacedaf91f0e6129b467eefad331b test/cli/commands_test.py
