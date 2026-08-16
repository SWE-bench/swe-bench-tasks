#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 2b93a26e6f15129fd1846bee52f51077eef7ca0c
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 2b93a26e6f15129fd1846bee52f51077eef7ca0c test/core/templaters/jinja_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/core/templaters/jinja_test.py b/test/core/templaters/jinja_test.py
--- a/test/core/templaters/jinja_test.py
+++ b/test/core/templaters/jinja_test.py
@@ -335,6 +335,58 @@ class RawTemplatedTestCase(NamedTuple):
                 "\n",
             ],
         ),
+        RawTemplatedTestCase(
+            "set_multiple_variables_and_define_macro",
+            """{% macro echo(text) %}
+{{text}}
+{% endmacro %}
+
+{% set a, b = 1, 2 %}
+
+SELECT
+    {{ echo(a) }},
+    {{ echo(b) }}""",
+            "\n\n\n\nSELECT\n    \n1\n,\n    \n2\n",
+            [
+                "{% macro echo(text) %}",
+                "\n",
+                "{{text}}",
+                "\n",
+                "{% endmacro %}",
+                "\n\n",
+                "{% set a, b = 1, 2 %}",
+                "\n\nSELECT\n    ",
+                "{{ echo(a) }}",
+                ",\n    ",
+                "{{ echo(b) }}",
+            ],
+            [
+                "",
+                "",
+                "",
+                "",
+                "",
+                "\n\n",
+                "",
+                "\n\nSELECT\n    ",
+                "\n1\n",
+                ",\n    ",
+                "\n2\n",
+            ],
+            [
+                "{% macro echo(text) %}",
+                "\n",
+                "{{text}}",
+                "\n",
+                "{% endmacro %}",
+                "\n\n",
+                "{% set a, b = 1, 2 %}",
+                "\n\nSELECT\n    ",
+                "{{ echo(a) }}",
+                ",\n    ",
+                "{{ echo(b) }}",
+            ],
+        ),
     ],
     ids=lambda case: case.name,
 )

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/core/templaters/jinja_test.py
: '>>>>> End Test Output'
git checkout 2b93a26e6f15129fd1846bee52f51077eef7ca0c test/core/templaters/jinja_test.py
