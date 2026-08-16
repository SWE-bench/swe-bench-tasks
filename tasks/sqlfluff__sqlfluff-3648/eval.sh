#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff e56fc6002dac0fb7eb446d58bd8aa7a839908535
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout e56fc6002dac0fb7eb446d58bd8aa7a839908535 test/core/templaters/jinja_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/core/templaters/jinja_test.py b/test/core/templaters/jinja_test.py
--- a/test/core/templaters/jinja_test.py
+++ b/test/core/templaters/jinja_test.py
@@ -697,6 +697,14 @@ def test__templater_jinja_slice_template(test, result):
     ] == result
 
 
+def _statement(*args, **kwargs):
+    return "_statement"
+
+
+def _load_result(*args, **kwargs):
+    return "_load_result"
+
+
 @pytest.mark.parametrize(
     "raw_file,override_context,result",
     [
@@ -1118,6 +1126,32 @@ def test__templater_jinja_slice_template(test, result):
                 ("literal", slice(131, 132, None), slice(88, 89, None)),
             ],
         ),
+        (
+            """{{ statement('variables', fetch_result=true) }}
+""",
+            dict(
+                statement=_statement,
+                load_result=_load_result,
+            ),
+            [
+                ("templated", slice(0, 47, None), slice(0, 10, None)),
+                ("literal", slice(47, 48, None), slice(10, 11, None)),
+            ],
+        ),
+        (
+            """{% call statement('variables', fetch_result=true) %}select 1 as test{% endcall %}
+""",
+            dict(
+                statement=_statement,
+                load_result=_load_result,
+            ),
+            [
+                ("templated", slice(0, 52, None), slice(0, 10, None)),
+                ("literal", slice(52, 68, None), slice(10, 10, None)),
+                ("block_end", slice(68, 81, None), slice(10, 10, None)),
+                ("literal", slice(81, 82, None), slice(10, 11, None)),
+            ],
+        ),
     ],
 )
 def test__templater_jinja_slice_file(raw_file, override_context, result, caplog):

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/core/templaters/jinja_test.py
: '>>>>> End Test Output'
git checkout e56fc6002dac0fb7eb446d58bd8aa7a839908535 test/core/templaters/jinja_test.py
