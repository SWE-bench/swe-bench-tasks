#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff bcaecce5634a30313e574deae101ee017ffeff17
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout bcaecce5634a30313e574deae101ee017ffeff17 tests/unittest_protocols.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/unittest_protocols.py b/tests/unittest_protocols.py
--- a/tests/unittest_protocols.py
+++ b/tests/unittest_protocols.py
@@ -16,7 +16,7 @@
 from astroid.const import PY38_PLUS, PY310_PLUS
 from astroid.exceptions import InferenceError
 from astroid.manager import AstroidManager
-from astroid.util import Uninferable
+from astroid.util import Uninferable, UninferableBase
 
 
 @contextlib.contextmanager
@@ -125,7 +125,7 @@ def test_assigned_stmts_starred_for(self) -> None:
         assert isinstance(assigned, astroid.List)
         assert assigned.as_string() == "[1, 2]"
 
-    def _get_starred_stmts(self, code: str) -> list | Uninferable:
+    def _get_starred_stmts(self, code: str) -> list | UninferableBase:
         assign_stmt = extract_node(f"{code} #@")
         starred = next(assign_stmt.nodes_of_class(nodes.Starred))
         return next(starred.assigned_stmts())
@@ -136,7 +136,7 @@ def _helper_starred_expected_const(self, code: str, expected: list[int]) -> None
         stmts = stmts.elts
         self.assertConstNodesEqual(expected, stmts)
 
-    def _helper_starred_expected(self, code: str, expected: Uninferable) -> None:
+    def _helper_starred_expected(self, code: str, expected: UninferableBase) -> None:
         stmts = self._get_starred_stmts(code)
         self.assertEqual(expected, stmts)
 

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/unittest_protocols.py
: '>>>>> End Test Output'
git checkout bcaecce5634a30313e574deae101ee017ffeff17 tests/unittest_protocols.py
