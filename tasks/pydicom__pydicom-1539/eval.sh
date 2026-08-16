#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff a125a02132c2db5ff5cad445e4722802dd5a8d55
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout a125a02132c2db5ff5cad445e4722802dd5a8d55 pydicom/tests/test_filewriter.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_filewriter.py b/pydicom/tests/test_filewriter.py
--- a/pydicom/tests/test_filewriter.py
+++ b/pydicom/tests/test_filewriter.py
@@ -474,6 +474,20 @@ def test_write_ascii_vr_with_padding(self):
         data_elem = DataElement(0x00080060, 'CS', b'REG')
         self.check_data_element(data_elem, expected)
 
+    def test_write_OB_odd(self):
+        """Test an odd-length OB element is padded during write"""
+        value = b'\x00\x01\x02'
+        elem = DataElement(0x7FE00010, 'OB', value)
+        encoded_elem = self.encode_element(elem)
+        ref_bytes = b'\xe0\x7f\x10\x00\x04\x00\x00\x00' + value + b"\x00"
+        assert ref_bytes == encoded_elem
+
+        # Empty data
+        elem.value = b''
+        encoded_elem = self.encode_element(elem)
+        ref_bytes = b'\xe0\x7f\x10\x00\x00\x00\x00\x00'
+        assert ref_bytes == encoded_elem
+
     def test_write_OD_implicit_little(self):
         """Test writing elements with VR of OD works correctly."""
         # VolumetricCurvePoints

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_filewriter.py
: '>>>>> End Test Output'
git checkout a125a02132c2db5ff5cad445e4722802dd5a8d55 pydicom/tests/test_filewriter.py
