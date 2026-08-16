#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff c3defb095b1aa7fe23c4bd430fdff2ce6ed6161d
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout c3defb095b1aa7fe23c4bd430fdff2ce6ed6161d test/cli/commands_test.py test/core/linter_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/cli/commands_test.py b/test/cli/commands_test.py
--- a/test/cli/commands_test.py
+++ b/test/cli/commands_test.py
@@ -1203,7 +1203,10 @@ def test__cli__command_lint_serialize_from_stdin(serialize, sql, expected, exit_
 def test__cli__command_fail_nice_not_found(command):
     """Check commands fail as expected when then don't find files."""
     result = invoke_assert_code(args=command, ret_code=2)
-    assert "could not be accessed" in result.output
+    assert (
+        "User Error: Specified path does not exist. Check it/they "
+        "exist(s): this_file_does_not_exist.sql"
+    ) in result.output
 
 
 @patch("click.utils.should_strip_ansi")
diff --git a/test/core/linter_test.py b/test/core/linter_test.py
--- a/test/core/linter_test.py
+++ b/test/core/linter_test.py
@@ -16,6 +16,7 @@
     SQLBaseError,
     SQLLintError,
     SQLParseError,
+    SQLFluffUserError,
 )
 from sqlfluff.cli.formatters import OutputStreamFormatter
 from sqlfluff.cli.outputstream import make_output_stream
@@ -120,9 +121,9 @@ def test__linter__skip_large_bytes(filesize, raises_skip):
 
 
 def test__linter__path_from_paths__not_exist():
-    """Test extracting paths from a file path."""
+    """Test that the right errors are raise when a file doesn't exist."""
     lntr = Linter()
-    with pytest.raises(IOError):
+    with pytest.raises(SQLFluffUserError):
         lntr.paths_from_path("asflekjfhsakuefhse")
 
 

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/cli/commands_test.py test/core/linter_test.py
: '>>>>> End Test Output'
git checkout c3defb095b1aa7fe23c4bd430fdff2ce6ed6161d test/cli/commands_test.py test/core/linter_test.py
