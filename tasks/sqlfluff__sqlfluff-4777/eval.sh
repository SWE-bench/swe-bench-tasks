#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 0243d4a1ba29e6cc3dc96bd9ea178d0f8a576a8f
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 0243d4a1ba29e6cc3dc96bd9ea178d0f8a576a8f test/cli/commands_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/cli/commands_test.py b/test/cli/commands_test.py
--- a/test/cli/commands_test.py
+++ b/test/cli/commands_test.py
@@ -1940,8 +1940,8 @@ def test__cli__fix_multiple_errors_quiet_force():
     )
     normalised_output = result.output.replace("\\", "/")
     assert normalised_output.startswith(
-        """1 fixable linting violations found
-== [test/fixtures/linter/multiple_sql_errors.sql] FIXED"""
+        """== [test/fixtures/linter/multiple_sql_errors.sql] FIXED
+1 fixable linting violations found"""
     )
 
 

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/cli/commands_test.py
: '>>>>> End Test Output'
git checkout 0243d4a1ba29e6cc3dc96bd9ea178d0f8a576a8f test/cli/commands_test.py
