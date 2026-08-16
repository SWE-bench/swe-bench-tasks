#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff c9c498348174b38ce35bfe001353c8ebea262802
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout c9c498348174b38ce35bfe001353c8ebea262802 tests/unittest_inference.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/unittest_inference.py b/tests/unittest_inference.py
--- a/tests/unittest_inference.py
+++ b/tests/unittest_inference.py
@@ -6154,5 +6154,26 @@ def test_issue926_binop_referencing_same_name_is_not_uninferable():
     assert inferred[0].value == 3
 
 
+def test_issue_1090_infer_yield_type_base_class():
+    code = """
+import contextlib
+
+class A:
+    @contextlib.contextmanager
+    def get(self):
+        yield self
+
+class B(A):
+    def play():
+        pass
+
+with B().get() as b:
+    b
+b
+    """
+    node = extract_node(code)
+    assert next(node.infer()).pytype() == ".B"
+
+
 if __name__ == "__main__":
     unittest.main()

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/unittest_inference.py
: '>>>>> End Test Output'
git checkout c9c498348174b38ce35bfe001353c8ebea262802 tests/unittest_inference.py
