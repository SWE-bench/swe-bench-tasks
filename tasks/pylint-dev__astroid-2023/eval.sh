#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 2108ae51b516458243c249cf67301cb387e33afa
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 2108ae51b516458243c249cf67301cb387e33afa tests/test_utils.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_utils.py b/tests/test_utils.py
--- a/tests/test_utils.py
+++ b/tests/test_utils.py
@@ -4,7 +4,10 @@
 
 import unittest
 
-from astroid import Uninferable, builder, nodes
+import pytest
+
+from astroid import Uninferable, builder, extract_node, nodes
+from astroid.const import PY38_PLUS
 from astroid.exceptions import InferenceError
 
 
@@ -30,6 +33,78 @@ def test_not_exclusive(self) -> None:
         self.assertEqual(nodes.are_exclusive(xass1, xnames[1]), False)
         self.assertEqual(nodes.are_exclusive(xass1, xnames[2]), False)
 
+    @pytest.mark.skipif(not PY38_PLUS, reason="needs assignment expressions")
+    def test_not_exclusive_walrus_operator(self) -> None:
+        node_if, node_body, node_or_else = extract_node(
+            """
+        if val := True:  #@
+            print(val)  #@
+        else:
+            print(val)  #@
+        """
+        )
+        node_if: nodes.If
+        node_walrus = next(node_if.nodes_of_class(nodes.NamedExpr))
+
+        assert nodes.are_exclusive(node_walrus, node_if) is False
+        assert nodes.are_exclusive(node_walrus, node_body) is False
+        assert nodes.are_exclusive(node_walrus, node_or_else) is False
+
+        assert nodes.are_exclusive(node_if, node_body) is False
+        assert nodes.are_exclusive(node_if, node_or_else) is False
+        assert nodes.are_exclusive(node_body, node_or_else) is True
+
+    @pytest.mark.skipif(not PY38_PLUS, reason="needs assignment expressions")
+    def test_not_exclusive_walrus_multiple(self) -> None:
+        node_if, body_1, body_2, or_else_1, or_else_2 = extract_node(
+            """
+        if (val := True) or (val_2 := True):  #@
+            print(val)  #@
+            print(val_2)  #@
+        else:
+            print(val)  #@
+            print(val_2)  #@
+        """
+        )
+        node_if: nodes.If
+        walruses = list(node_if.nodes_of_class(nodes.NamedExpr))
+
+        assert nodes.are_exclusive(node_if, walruses[0]) is False
+        assert nodes.are_exclusive(node_if, walruses[1]) is False
+
+        assert nodes.are_exclusive(walruses[0], walruses[1]) is False
+
+        assert nodes.are_exclusive(walruses[0], body_1) is False
+        assert nodes.are_exclusive(walruses[0], body_2) is False
+        assert nodes.are_exclusive(walruses[1], body_1) is False
+        assert nodes.are_exclusive(walruses[1], body_2) is False
+
+        assert nodes.are_exclusive(walruses[0], or_else_1) is False
+        assert nodes.are_exclusive(walruses[0], or_else_2) is False
+        assert nodes.are_exclusive(walruses[1], or_else_1) is False
+        assert nodes.are_exclusive(walruses[1], or_else_2) is False
+
+    @pytest.mark.skipif(not PY38_PLUS, reason="needs assignment expressions")
+    def test_not_exclusive_walrus_operator_nested(self) -> None:
+        node_if, node_body, node_or_else = extract_node(
+            """
+        if all((last_val := i) % 2 == 0 for i in range(10)): #@
+            print(last_val)  #@
+        else:
+            print(last_val)  #@
+        """
+        )
+        node_if: nodes.If
+        node_walrus = next(node_if.nodes_of_class(nodes.NamedExpr))
+
+        assert nodes.are_exclusive(node_walrus, node_if) is False
+        assert nodes.are_exclusive(node_walrus, node_body) is False
+        assert nodes.are_exclusive(node_walrus, node_or_else) is False
+
+        assert nodes.are_exclusive(node_if, node_body) is False
+        assert nodes.are_exclusive(node_if, node_or_else) is False
+        assert nodes.are_exclusive(node_body, node_or_else) is True
+
     def test_if(self) -> None:
         module = builder.parse(
             """

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/test_utils.py
: '>>>>> End Test Output'
git checkout 2108ae51b516458243c249cf67301cb387e33afa tests/test_utils.py
