#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 5c104a71c54ce4ed83401d62dfaaa86be38e5aff
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 5c104a71c54ce4ed83401d62dfaaa86be38e5aff test/core/linter_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/core/linter_test.py b/test/core/linter_test.py
--- a/test/core/linter_test.py
+++ b/test/core/linter_test.py
@@ -708,18 +708,42 @@ def test_linter_noqa_with_templating():
     assert not result.get_violations()
 
 
+def test_linter_noqa_template_errors():
+    """Similar to test_linter_noqa, but uses templating (Jinja)."""
+    lntr = Linter(
+        config=FluffConfig(
+            overrides={
+                "templater": "jinja",
+            }
+        )
+    )
+    sql = """select * --noqa: TMP
+from raw
+where
+    balance_date >= {{ execution_date - macros.timedelta() }}  --noqa: TMP
+"""
+    result = lntr.lint_string(sql)
+    assert not result.get_violations()
+
+
 def test_linter_noqa_prs():
     """Test "noqa" feature to ignore PRS at the higher "Linter" level."""
     lntr = Linter(
         config=FluffConfig(
             overrides={
+                "dialect": "bigquery",
                 "exclude_rules": "L050",
             }
         )
     )
     sql = """
-    SELECT col_a AS a
-    FROM foo;, -- noqa: PRS
+    CREATE TABLE IF NOT EXISTS
+    Test.events (userID STRING,
+    eventName STRING,
+    eventID INTEGER,
+    device STRUCT < mobileBrandName STRING, -- noqa: PRS
+    mobileModelName STRING>);
+    Insert into Test.events VALUES ("1","abc",123,STRUCT("htc","10"));
         """
     result = lntr.lint_string(sql)
     violations = result.get_violations()

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/core/linter_test.py
: '>>>>> End Test Output'
git checkout 5c104a71c54ce4ed83401d62dfaaa86be38e5aff test/core/linter_test.py
