#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 88ca0bff105c75a632d7351acb6895b70230fa12
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 88ca0bff105c75a632d7351acb6895b70230fa12 pydicom/tests/test_filewriter.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_filewriter.py b/pydicom/tests/test_filewriter.py
--- a/pydicom/tests/test_filewriter.py
+++ b/pydicom/tests/test_filewriter.py
@@ -2513,20 +2513,31 @@ def test_writing_too_big_data_in_explicit_encoding(self):
                                  large_value,
                                  is_undefined_length=False)
         write_data_element(self.fp, pixel_data)
+        self.fp.seek(0)
+        ds = read_dataset(self.fp, True, True)
+        assert 'DS' == ds[0x30040058].VR
 
         self.fp = DicomBytesIO()
         self.fp.is_little_endian = True
         self.fp.is_implicit_VR = False
-        # shall raise if trying to write it with explicit transfer syntax,
-        # where the length field is 2 bytes long
-        expected_message = (r'The value for the data element \(3004, 0058\) '
-                            r'exceeds the size of 64 kByte ')
-        with pytest.raises(ValueError, match=expected_message):
+
+        msg = (r'The value for the data element \(3004, 0058\) exceeds the '
+               r'size of 64 kByte and cannot be written in an explicit '
+               r'transfer syntax. The data element VR is changed from '
+               r'"DS" to "UN" to allow saving the data.')
+
+        with pytest.warns(UserWarning, match=msg):
             write_data_element(self.fp, pixel_data)
+        self.fp.seek(0)
+        ds = read_dataset(self.fp, False, True)
+        assert 'UN' == ds[0x30040058].VR
 
+        # we expect the same behavior in Big Endian transfer syntax
         self.fp = DicomBytesIO()
         self.fp.is_little_endian = False
         self.fp.is_implicit_VR = False
-        # we expect the same behavior in Big Endian transfer syntax
-        with pytest.raises(ValueError, match=expected_message):
+        with pytest.warns(UserWarning, match=msg):
             write_data_element(self.fp, pixel_data)
+        self.fp.seek(0)
+        ds = read_dataset(self.fp, False, False)
+        assert 'UN' == ds[0x30040058].VR

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_filewriter.py
: '>>>>> End Test Output'
git checkout 88ca0bff105c75a632d7351acb6895b70230fa12 pydicom/tests/test_filewriter.py
