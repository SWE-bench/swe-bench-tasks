#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff e3f77d58f56149f9c8db3b790ef263b9853a9cb5
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout e3f77d58f56149f9c8db3b790ef263b9853a9cb5 test/core/templaters/jinja_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/core/templaters/jinja_test.py b/test/core/templaters/jinja_test.py
--- a/test/core/templaters/jinja_test.py
+++ b/test/core/templaters/jinja_test.py
@@ -1091,6 +1091,23 @@ def _load_result(*args, **kwargs):
                 ("literal", slice(132, 133, None), slice(34, 35, None)),
             ],
         ),
+        (
+            # Tests Jinja "do" directive. Should be treated as a
+            # templated instead of block - issue 4603.
+            """{% do true %}
+
+{% if true %}
+    select 1
+{% endif %}""",
+            None,
+            [
+                ("templated", slice(0, 13, None), slice(0, 0, None)),
+                ("literal", slice(13, 15, None), slice(0, 2, None)),
+                ("block_start", slice(15, 28, None), slice(2, 2, None)),
+                ("literal", slice(28, 42, None), slice(2, 16, None)),
+                ("block_end", slice(42, 53, None), slice(16, 16, None)),
+            ],
+        ),
         (
             # Tests issue 2541, a bug where the {%- endfor %} was causing
             # IndexError: list index out of range.

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/core/templaters/jinja_test.py
: '>>>>> End Test Output'
git checkout e3f77d58f56149f9c8db3b790ef263b9853a9cb5 test/core/templaters/jinja_test.py
