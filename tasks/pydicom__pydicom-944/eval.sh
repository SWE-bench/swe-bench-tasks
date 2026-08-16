#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff a0300a69a1da1626caef0d9738cff29b17ce79cc
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout a0300a69a1da1626caef0d9738cff29b17ce79cc pydicom/tests/test_values.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_values.py b/pydicom/tests/test_values.py
--- a/pydicom/tests/test_values.py
+++ b/pydicom/tests/test_values.py
@@ -86,6 +86,21 @@ def test_single_value_with_delimiters(self):
         expected = u'Διονυσιος\r\nJérôme/Люкceмбypг\tJérôme'
         assert expected == convert_single_string(bytestring, encodings)
 
+    def test_value_ending_with_padding(self):
+        bytestring = b'Value ending with spaces   '
+        assert 'Value ending with spaces' == convert_single_string(bytestring)
+        assert 'Value ending with spaces' == convert_text(bytestring)
+
+        bytestring = b'Values  \\with spaces   '
+        assert ['Values', 'with spaces'] == convert_text(bytestring)
+
+        bytestring = b'Value ending with zeros\0\0\0'
+        assert 'Value ending with zeros' == convert_single_string(bytestring)
+        assert 'Value ending with zeros' == convert_text(bytestring)
+
+        bytestring = b'Values\0\0\\with zeros\0'
+        assert ['Values', 'with zeros'] == convert_text(bytestring)
+
 
 class TestConvertAT(object):
     def test_big_endian(self):

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_values.py
: '>>>>> End Test Output'
git checkout a0300a69a1da1626caef0d9738cff29b17ce79cc pydicom/tests/test_values.py
