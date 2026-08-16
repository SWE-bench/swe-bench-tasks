#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 66fd602d0824138f212082c8fdf381266a9edad3
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 66fd602d0824138f212082c8fdf381266a9edad3 test/core/linter_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/core/linter_test.py b/test/core/linter_test.py
--- a/test/core/linter_test.py
+++ b/test/core/linter_test.py
@@ -407,8 +407,9 @@ def test__linter__empty_file():
         (
             False,
             [
-                ("L006", 3, 16),
-                ("L006", 3, 16),
+                # there are still two of each because L006 checks
+                # for both *before* and *after* the operator.
+                # The deduplication filter makes sure there aren't 4.
                 ("L006", 3, 16),
                 ("L006", 3, 16),
                 ("L006", 3, 39),
@@ -418,7 +419,11 @@ def test__linter__empty_file():
     ],
 )
 def test__linter__mask_templated_violations(ignore_templated_areas, check_tuples):
-    """Test linter masks files properly around templated content."""
+    """Test linter masks files properly around templated content.
+
+    NOTE: this also tests deduplication of fixes which have the same
+    source position. i.e. `LintedFile.deduplicate_in_source_space()`.
+    """
     lntr = Linter(
         config=FluffConfig(
             overrides={

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/core/linter_test.py
: '>>>>> End Test Output'
git checkout 66fd602d0824138f212082c8fdf381266a9edad3 test/core/linter_test.py
