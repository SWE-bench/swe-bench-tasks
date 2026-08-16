#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff d2394a3e24236106355418e102b1bb0f1bef879c
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout d2394a3e24236106355418e102b1bb0f1bef879c tests/unittest_modutils.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/unittest_modutils.py b/tests/unittest_modutils.py
--- a/tests/unittest_modutils.py
+++ b/tests/unittest_modutils.py
@@ -301,6 +301,18 @@ def test_knownValues_is_relative_1(self):
     def test_knownValues_is_relative_3(self):
         self.assertFalse(modutils.is_relative("astroid", astroid.__path__[0]))
 
+    def test_knownValues_is_relative_4(self):
+        self.assertTrue(
+            modutils.is_relative("util", astroid.interpreter._import.spec.__file__)
+        )
+
+    def test_knownValues_is_relative_5(self):
+        self.assertFalse(
+            modutils.is_relative(
+                "objectmodel", astroid.interpreter._import.spec.__file__
+            )
+        )
+
     def test_deep_relative(self):
         self.assertTrue(modutils.is_relative("ElementTree", xml.etree.__path__[0]))
 

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/unittest_modutils.py
: '>>>>> End Test Output'
git checkout d2394a3e24236106355418e102b1bb0f1bef879c tests/unittest_modutils.py
