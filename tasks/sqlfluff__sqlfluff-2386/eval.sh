#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 23d698607b45b8469c766b521d27e9a6e92e8739
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 23d698607b45b8469c766b521d27e9a6e92e8739 test/core/rules/docstring_test.py test/rules/std_L054_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/core/rules/docstring_test.py b/test/core/rules/docstring_test.py
--- a/test/core/rules/docstring_test.py
+++ b/test/core/rules/docstring_test.py
@@ -1,6 +1,7 @@
 """Test rules docstring."""
 import pytest
 
+from sqlfluff import lint
 from sqlfluff.core.plugin.host import get_plugin_manager
 
 KEYWORD_ANTI = "\n    | **Anti-pattern**"
@@ -34,3 +35,19 @@ def test_keyword_anti_before_best():
                 assert rule.__doc__.index(KEYWORD_ANTI) < rule.__doc__.index(
                     KEYWORD_BEST
                 ), f"{rule.__name__} keyword {KEYWORD_BEST} appears before {KEYWORD_ANTI}"
+
+
+def test_backtick_replace():
+    """Test replacing docstring double backticks for lint results."""
+    sql = """
+    SELECT
+        foo.a,
+        bar.b
+    FROM foo
+    JOIN bar;
+    """
+    result = lint(sql, rules=["L051"])
+    # L051 docstring looks like:
+    # ``INNER JOIN`` must be fully qualified.
+    # Check the double bacticks (``) get replaced by a single quote (').
+    assert result[0]["description"] == "'INNER JOIN' must be fully qualified."
diff --git a/test/rules/std_L054_test.py b/test/rules/std_L054_test.py
--- a/test/rules/std_L054_test.py
+++ b/test/rules/std_L054_test.py
@@ -29,7 +29,7 @@ def test__rules__std_L054_raised() -> None:
     assert len(results_l054) == 2
     assert (
         results_l054[0]["description"]
-        == "Inconsistent column references in ``GROUP BY/ORDER BY`` clauses."
+        == "Inconsistent column references in 'GROUP BY/ORDER BY' clauses."
     )
 
 

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/core/rules/docstring_test.py test/rules/std_L054_test.py
: '>>>>> End Test Output'
git checkout 23d698607b45b8469c766b521d27e9a6e92e8739 test/core/rules/docstring_test.py test/rules/std_L054_test.py
