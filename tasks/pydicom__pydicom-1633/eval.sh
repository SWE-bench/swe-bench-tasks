#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 98ac88706e7ab17cd279c94949ac6af4e87f341d
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 98ac88706e7ab17cd279c94949ac6af4e87f341d pydicom/tests/test_valuerep.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_valuerep.py b/pydicom/tests/test_valuerep.py
--- a/pydicom/tests/test_valuerep.py
+++ b/pydicom/tests/test_valuerep.py
@@ -603,6 +603,13 @@ def test_enforce_valid_values_length(self):
             valuerep.DSfloat('3.141592653589793',
                              validation_mode=config.RAISE)
 
+    def test_handle_missing_leading_zero(self):
+        """Test that no error is raised with maximum length DS string
+        without leading zero."""
+        # Regression test for #1632
+        valuerep.DSfloat(".002006091181818",
+                         validation_mode=config.RAISE)
+
     def test_DSfloat_auto_format(self):
         """Test creating a value using DSfloat copies auto_format"""
         x = DSfloat(math.pi, auto_format=True)

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_valuerep.py
: '>>>>> End Test Output'
git checkout 98ac88706e7ab17cd279c94949ac6af4e87f341d pydicom/tests/test_valuerep.py
