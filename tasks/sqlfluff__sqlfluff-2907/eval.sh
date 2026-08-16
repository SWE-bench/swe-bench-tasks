#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 305159ea643baf6b4744b98c3566613754b2f659
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 305159ea643baf6b4744b98c3566613754b2f659 test/core/templaters/jinja_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/core/templaters/jinja_test.py b/test/core/templaters/jinja_test.py
--- a/test/core/templaters/jinja_test.py
+++ b/test/core/templaters/jinja_test.py
@@ -411,6 +411,20 @@ def test__templater_jinja_error_variable():
     assert any(v.rule_code() == "TMP" and v.line_no == 1 for v in vs)
 
 
+def test__templater_jinja_dynamic_variable_no_violations():
+    """Test no templater violation for variable defined within template."""
+    t = JinjaTemplater(override_context=dict(blah="foo"))
+    instr = """{% if True %}
+    {% set some_var %}1{% endset %}
+    SELECT {{some_var}}
+{% endif %}
+"""
+    outstr, vs = t.process(in_str=instr, fname="test", config=FluffConfig())
+    assert str(outstr) == "\n    \n    SELECT 1\n\n"
+    # Check we have no violations.
+    assert len(vs) == 0
+
+
 def test__templater_jinja_error_syntax():
     """Test syntax problems in the jinja templater."""
     t = JinjaTemplater()

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/core/templaters/jinja_test.py
: '>>>>> End Test Output'
git checkout 305159ea643baf6b4744b98c3566613754b2f659 test/core/templaters/jinja_test.py
