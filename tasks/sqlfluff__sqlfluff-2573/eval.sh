#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 8822bf4d831ccbf6bc63a44b34978daf6939d996
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 8822bf4d831ccbf6bc63a44b34978daf6939d996 test/core/linter_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/core/linter_test.py b/test/core/linter_test.py
--- a/test/core/linter_test.py
+++ b/test/core/linter_test.py
@@ -1,10 +1,12 @@
 """The Test file for the linter class."""
 
-import pytest
+import os
 import logging
 from typing import List
 from unittest.mock import patch
 
+import pytest
+
 from sqlfluff.core import Linter, FluffConfig
 from sqlfluff.core.linter import runner
 from sqlfluff.core.errors import SQLLexError, SQLBaseError, SQLLintError, SQLParseError
@@ -91,6 +93,23 @@ def test__linter__path_from_paths__explicit_ignore():
     assert len(paths) == 0
 
 
+def test__linter__path_from_paths__sqlfluffignore_current_directory():
+    """Test that .sqlfluffignore in the current directory is read when dir given."""
+    oldcwd = os.getcwd()
+    try:
+        os.chdir("test/fixtures/linter/sqlfluffignore")
+        lntr = Linter()
+        paths = lntr.paths_from_path(
+            "path_a/",
+            ignore_non_existent_files=True,
+            ignore_files=True,
+            working_path="test/fixtures/linter/sqlfluffignore/",
+        )
+        assert len(paths) == 0
+    finally:
+        os.chdir(oldcwd)
+
+
 def test__linter__path_from_paths__dot():
     """Test extracting paths from a dot."""
     lntr = Linter()

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/core/linter_test.py
: '>>>>> End Test Output'
git checkout 8822bf4d831ccbf6bc63a44b34978daf6939d996 test/core/linter_test.py
