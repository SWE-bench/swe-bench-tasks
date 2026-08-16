#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 500505877769ab02504427284e4efdf832d299ea
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 500505877769ab02504427284e4efdf832d299ea test/core/templaters/jinja_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/core/templaters/jinja_test.py b/test/core/templaters/jinja_test.py
--- a/test/core/templaters/jinja_test.py
+++ b/test/core/templaters/jinja_test.py
@@ -75,6 +75,18 @@ def test__templater_jinja_error_catatrophic():
     assert len(vs) > 0
 
 
+def test__templater_jinja_lint_empty():
+    """Check that parsing a file which renders to an empty string.
+
+    No exception should be raised, but the parsed tree should be None.
+    """
+    lntr = Linter()
+    parsed = lntr.parse_string(in_str='{{ "" }}')
+    assert parsed.templated_file.source_str == '{{ "" }}'
+    assert parsed.templated_file.templated_str == ""
+    assert parsed.tree is None
+
+
 def assert_structure(yaml_loader, path, code_only=True, include_meta=False):
     """Check that a parsed sql file matches the yaml file with the same name."""
     lntr = Linter()

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/core/templaters/jinja_test.py
: '>>>>> End Test Output'
git checkout 500505877769ab02504427284e4efdf832d299ea test/core/templaters/jinja_test.py
