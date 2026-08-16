#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 1f099ae0f75f0e2ed402a21702e584aac54a30ef
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 1f099ae0f75f0e2ed402a21702e584aac54a30ef pydicom/tests/test_charset.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_charset.py b/pydicom/tests/test_charset.py
--- a/pydicom/tests/test_charset.py
+++ b/pydicom/tests/test_charset.py
@@ -140,6 +140,15 @@ def test_bad_charset(self):
         pydicom.charset.decode_element(elem, [])
         assert 'iso8859' in elem.value.encodings
 
+    def test_empty_charset(self):
+        """Empty charset defaults to ISO IR 6"""
+        elem = DataElement(0x00100010, 'PN', 'CITIZEN')
+        pydicom.charset.decode_element(elem, [''])
+        assert ('iso8859',) == elem.value.encodings
+        elem = DataElement(0x00100010, 'PN', 'CITIZEN')
+        pydicom.charset.decode_element(elem, None)
+        assert ('iso8859',) == elem.value.encodings
+
     def test_bad_encoded_single_encoding(self, allow_invalid_values):
         """Test handling bad encoding for single encoding"""
         elem = DataElement(0x00100010, 'PN',
@@ -189,6 +198,15 @@ def test_convert_python_encodings(self):
         encodings = ['iso_ir_126', 'iso_ir_144']
         assert encodings == pydicom.charset.convert_encodings(encodings)
 
+    def test_convert_empty_encoding(self):
+        """Test that empty encodings are handled as default encoding"""
+        encodings = ''
+        assert ['iso8859'] == pydicom.charset.convert_encodings(encodings)
+        encodings = ['']
+        assert ['iso8859'] == pydicom.charset.convert_encodings(encodings)
+        encodings = None
+        assert ['iso8859'] == pydicom.charset.convert_encodings(encodings)
+
     def test_bad_decoded_multi_byte_encoding(self, allow_invalid_values):
         """Test handling bad encoding for single encoding"""
         elem = DataElement(0x00100010, 'PN',

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_charset.py
: '>>>>> End Test Output'
git checkout 1f099ae0f75f0e2ed402a21702e584aac54a30ef pydicom/tests/test_charset.py
