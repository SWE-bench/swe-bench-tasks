#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 262010b91cf5616de242dad504c788e9cd33ac58
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 262010b91cf5616de242dad504c788e9cd33ac58 test/cli/commands_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/cli/commands_test.py b/test/cli/commands_test.py
--- a/test/cli/commands_test.py
+++ b/test/cli/commands_test.py
@@ -687,6 +687,70 @@ def test__cli__fix_error_handling_behavior(sql, fix_args, fixed, exit_code, tmpd
             assert not fixed_path.is_file()
 
 
+@pytest.mark.parametrize(
+    "method,fix_even_unparsable",
+    [
+        ("command-line", False),
+        ("command-line", True),
+        ("config-file", False),
+        ("config-file", True),
+    ],
+)
+def test_cli_fix_even_unparsable(
+    method: str, fix_even_unparsable: bool, monkeypatch, tmpdir
+):
+    """Test the fix_even_unparsable option works from cmd line and config."""
+    sql_filename = "fix_even_unparsable.sql"
+    sql_path = str(tmpdir / sql_filename)
+    with open(sql_path, "w") as f:
+        print(
+            """SELECT my_col
+FROM my_schema.my_table
+where processdate ! 3
+""",
+            file=f,
+        )
+    options = [
+        "--dialect",
+        "ansi",
+        "-f",
+        "--fixed-suffix=FIXED",
+        sql_path,
+    ]
+    if method == "command-line":
+        if fix_even_unparsable:
+            options.append("--FIX-EVEN-UNPARSABLE")
+    else:
+        assert method == "config-file"
+        with open(str(tmpdir / ".sqlfluff"), "w") as f:
+            print(f"[sqlfluff]\nfix_even_unparsable = {fix_even_unparsable}", file=f)
+    # TRICKY: Switch current directory to the one with the SQL file. Otherwise,
+    # the setting doesn't work. That's because SQLFluff reads it in
+    # sqlfluff.cli.commands.fix(), prior to reading any file-specific settings
+    # (down in sqlfluff.core.linter.Linter._load_raw_file_and_config()).
+    monkeypatch.chdir(str(tmpdir))
+    invoke_assert_code(
+        ret_code=0 if fix_even_unparsable else 1,
+        args=[
+            fix,
+            options,
+        ],
+    )
+    fixed_path = str(tmpdir / "fix_even_unparsableFIXED.sql")
+    if fix_even_unparsable:
+        with open(fixed_path, "r") as f:
+            fixed_sql = f.read()
+            assert (
+                fixed_sql
+                == """SELECT my_col
+FROM my_schema.my_table
+WHERE processdate ! 3
+"""
+            )
+    else:
+        assert not os.path.isfile(fixed_path)
+
+
 _old_eval = BaseRule._eval
 _fix_counter = 0
 

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/cli/commands_test.py
: '>>>>> End Test Output'
git checkout 262010b91cf5616de242dad504c788e9cd33ac58 test/cli/commands_test.py
