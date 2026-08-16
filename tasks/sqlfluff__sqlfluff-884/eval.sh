#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff c0bad78f3fa9549591738c77f869724f721e6830
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout c0bad78f3fa9549591738c77f869724f721e6830 test/core/dialects/ansi_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/core/dialects/ansi_test.py b/test/core/dialects/ansi_test.py
--- a/test/core/dialects/ansi_test.py
+++ b/test/core/dialects/ansi_test.py
@@ -162,3 +162,14 @@ def test__dialect__ansi_specific_segment_not_parse(raw, err_locations, caplog):
     assert len(parsed.violations) > 0
     locs = [(v.line_no(), v.line_pos()) for v in parsed.violations]
     assert locs == err_locations
+
+
+def test__dialect__ansi_is_whitespace():
+    """Test proper tagging with is_whitespace."""
+    lnt = Linter()
+    with open("test/fixtures/parser/ansi/select_in_multiline_comment.sql") as f:
+        parsed = lnt.parse_string(f.read())
+    # Check all the segments that *should* be whitespace, ARE
+    for raw_seg in parsed.tree.iter_raw_seg():
+        if raw_seg.type in ("whitespace", "newline"):
+            assert raw_seg.is_whitespace

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/core/dialects/ansi_test.py
: '>>>>> End Test Output'
git checkout c0bad78f3fa9549591738c77f869724f721e6830 test/core/dialects/ansi_test.py
