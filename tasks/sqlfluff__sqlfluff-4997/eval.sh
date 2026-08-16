#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 50bbffd4672aa17af2651f40d533cf55048b7524
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 50bbffd4672aa17af2651f40d533cf55048b7524 test/core/config_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/core/config_test.py b/test/core/config_test.py
--- a/test/core/config_test.py
+++ b/test/core/config_test.py
@@ -459,6 +459,50 @@ def test__config__validate_configs_indirect():
         )
 
 
+@pytest.mark.parametrize(
+    "raw_sql",
+    [
+        (
+            # "types" not "type"
+            "-- sqlfluff:layout:types:comma:line_position:leading\n"
+            "SELECT 1"
+        ),
+        (
+            # Unsupported layout config length
+            "-- sqlfluff:layout:foo\n"
+            "SELECT 1"
+        ),
+        (
+            # Unsupported layout config length
+            "-- sqlfluff:layout:type:comma:bar\n"
+            "SELECT 1"
+        ),
+        (
+            # Unsupported layout config key ("foo")
+            "-- sqlfluff:layout:type:comma:foo:bar\n"
+            "SELECT 1"
+        ),
+        (
+            # Unsupported layout config key ("foo") [no space]
+            "--sqlfluff:layout:type:comma:foo:bar\n"
+            "SELECT 1"
+        ),
+    ],
+)
+def test__config__validate_configs_inline_layout(raw_sql):
+    """Test _validate_configs method of FluffConfig when used on a file.
+
+    This test covers both the validation of inline config
+    directives but also the validation of layout configs.
+    """
+    # Instantiate config object.
+    cfg = FluffConfig(configs={"core": {"dialect": "ansi"}})
+
+    # Try to process an invalid inline config. Make sure we get an error.
+    with pytest.raises(SQLFluffUserError):
+        cfg.process_raw_file_for_config(raw_sql, "test.sql")
+
+
 def test__config__validate_configs_precedence_same_file():
     """Test _validate_configs method of FluffConfig where there's a conflict."""
     # Check with a known conflicted value
@@ -528,19 +572,19 @@ def test__process_inline_config():
     cfg = FluffConfig(config_b)
     assert cfg.get("rules") == "LT03"
 
-    cfg.process_inline_config("-- sqlfluff:rules:LT02")
+    cfg.process_inline_config("-- sqlfluff:rules:LT02", "test.sql")
     assert cfg.get("rules") == "LT02"
 
     assert cfg.get("tab_space_size", section="indentation") == 4
-    cfg.process_inline_config("-- sqlfluff:indentation:tab_space_size:20")
+    cfg.process_inline_config("-- sqlfluff:indentation:tab_space_size:20", "test.sql")
     assert cfg.get("tab_space_size", section="indentation") == 20
 
     assert cfg.get("dialect") == "ansi"
     assert cfg.get("dialect_obj").name == "ansi"
-    cfg.process_inline_config("-- sqlfluff:dialect:postgres")
+    cfg.process_inline_config("-- sqlfluff:dialect:postgres", "test.sql")
     assert cfg.get("dialect") == "postgres"
     assert cfg.get("dialect_obj").name == "postgres"
 
     assert cfg.get("rulez") is None
-    cfg.process_inline_config("-- sqlfluff:rulez:LT06")
+    cfg.process_inline_config("-- sqlfluff:rulez:LT06", "test.sql")
     assert cfg.get("rulez") == "LT06"

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/core/config_test.py
: '>>>>> End Test Output'
git checkout 50bbffd4672aa17af2651f40d533cf55048b7524 test/core/config_test.py
