#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 514991036806e9cda2b12cef8ab3184ac373bd6c
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 514991036806e9cda2b12cef8ab3184ac373bd6c tests/test_nodes.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_nodes.py b/tests/test_nodes.py
--- a/tests/test_nodes.py
+++ b/tests/test_nodes.py
@@ -22,6 +22,7 @@
     Uninferable,
     bases,
     builder,
+    extract_node,
     nodes,
     parse,
     test_utils,
@@ -1975,3 +1976,38 @@ def test_str_repr_no_warnings(node):
     test_node = node(**args)
     str(test_node)
     repr(test_node)
+
+
+def test_arguments_contains_all():
+    """Ensure Arguments.arguments actually returns all available arguments"""
+
+    def manually_get_args(arg_node) -> set:
+        names = set()
+        if arg_node.args.vararg:
+            names.add(arg_node.args.vararg)
+        if arg_node.args.kwarg:
+            names.add(arg_node.args.kwarg)
+
+        names.update([x.name for x in arg_node.args.args])
+        names.update([x.name for x in arg_node.args.kwonlyargs])
+
+        return names
+
+    node = extract_node("""def a(fruit: str, *args, b=None, c=None, **kwargs): ...""")
+    assert manually_get_args(node) == {x.name for x in node.args.arguments}
+
+    node = extract_node("""def a(mango: int, b="banana", c=None, **kwargs): ...""")
+    assert manually_get_args(node) == {x.name for x in node.args.arguments}
+
+    node = extract_node("""def a(self, num = 10, *args): ...""")
+    assert manually_get_args(node) == {x.name for x in node.args.arguments}
+
+
+def test_arguments_default_value():
+    node = extract_node(
+        "def fruit(eat='please', *, peel='no', trim='yes', **kwargs): ..."
+    )
+    assert node.args.default_value("eat").value == "please"
+
+    node = extract_node("def fruit(seeds, flavor='good', *, peel='maybe'): ...")
+    assert node.args.default_value("flavor").value == "good"

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/test_nodes.py
: '>>>>> End Test Output'
git checkout 514991036806e9cda2b12cef8ab3184ac373bd6c tests/test_nodes.py
