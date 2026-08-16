#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff e840a7c54d3d8b5be2db1e66f34a5368c64fc3f7
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout e840a7c54d3d8b5be2db1e66f34a5368c64fc3f7 tests/unittest_nodes_lineno.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/unittest_nodes_lineno.py b/tests/unittest_nodes_lineno.py
--- a/tests/unittest_nodes_lineno.py
+++ b/tests/unittest_nodes_lineno.py
@@ -2,6 +2,7 @@
 
 import pytest
 
+import astroid
 from astroid import builder, nodes
 from astroid.const import PY38_PLUS, PY39_PLUS, PY310_PLUS
 
@@ -1221,3 +1222,14 @@ class X(Parent, var=42):
         assert (c1.body[0].lineno, c1.body[0].col_offset) == (4, 4)
         assert (c1.body[0].end_lineno, c1.body[0].end_col_offset) == (4, 8)
         # fmt: on
+
+    @staticmethod
+    def test_end_lineno_module() -> None:
+        """Tests for Module"""
+        code = """print()"""
+        module = astroid.parse(code)
+        assert isinstance(module, nodes.Module)
+        assert module.lineno == 0
+        assert module.col_offset is None
+        assert module.end_lineno is None
+        assert module.end_col_offset is None

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/unittest_nodes_lineno.py
: '>>>>> End Test Output'
git checkout e840a7c54d3d8b5be2db1e66f34a5368c64fc3f7 tests/unittest_nodes_lineno.py
