#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff caf0db105ddf389ff5025937fd5f3aa1e61e85e7
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout caf0db105ddf389ff5025937fd5f3aa1e61e85e7 pydicom/tests/test_filereader.py pydicom/tests/test_filewriter.py pydicom/tests/test_values.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_filereader.py b/pydicom/tests/test_filereader.py
--- a/pydicom/tests/test_filereader.py
+++ b/pydicom/tests/test_filereader.py
@@ -700,6 +700,20 @@ def test_lut_descriptor_singleton(self):
         assert elem.value == -2816
         assert elem.VR == 'SS'
 
+    def test_reading_of(self):
+        """Test reading a dataset with OF element."""
+        bs = DicomBytesIO(
+            b'\x28\x00\x01\x11\x53\x53\x06\x00\x00\xf5\x00\xf8\x10\x00'
+            b'\xe0\x7f\x08\x00\x4F\x46\x00\x00\x04\x00\x00\x00\x00\x01\x02\x03'
+        )
+        bs.is_little_endian = True
+        bs.is_implicit_VR = False
+
+        ds = dcmread(bs, force=True)
+        elem = ds['FloatPixelData']
+        assert 'OF' == elem.VR
+        assert b'\x00\x01\x02\x03' == elem.value
+
 
 class TestIncorrectVR(object):
     def setup(self):
diff --git a/pydicom/tests/test_filewriter.py b/pydicom/tests/test_filewriter.py
--- a/pydicom/tests/test_filewriter.py
+++ b/pydicom/tests/test_filewriter.py
@@ -21,10 +21,11 @@
 from pydicom.dataelem import DataElement, RawDataElement
 from pydicom.filebase import DicomBytesIO
 from pydicom.filereader import dcmread, read_dataset, read_file
-from pydicom.filewriter import (write_data_element, write_dataset,
-                                correct_ambiguous_vr, write_file_meta_info,
-                                correct_ambiguous_vr_element, write_numbers,
-                                write_PN, _format_DT, write_text)
+from pydicom.filewriter import (
+    write_data_element, write_dataset, correct_ambiguous_vr,
+    write_file_meta_info, correct_ambiguous_vr_element, write_numbers,
+    write_PN, _format_DT, write_text, write_OWvalue
+)
 from pydicom.multival import MultiValue
 from pydicom.sequence import Sequence
 from pydicom.uid import (ImplicitVRLittleEndian, ExplicitVRBigEndian,
@@ -2251,6 +2252,32 @@ def test_write_big_endian(self):
         assert fp.getvalue() == b'\x00\x01'
 
 
+class TestWriteOtherVRs(object):
+    """Tests for writing the 'O' VRs like OB, OW, OF, etc."""
+    def test_write_of(self):
+        """Test writing element with VR OF"""
+        fp = DicomBytesIO()
+        fp.is_little_endian = True
+        elem = DataElement(0x7fe00008, 'OF', b'\x00\x01\x02\x03')
+        write_OWvalue(fp, elem)
+        assert fp.getvalue() == b'\x00\x01\x02\x03'
+
+    def test_write_of_dataset(self):
+        """Test writing a dataset with an element with VR OF."""
+        fp = DicomBytesIO()
+        fp.is_little_endian = True
+        fp.is_implicit_VR = False
+        ds = Dataset()
+        ds.is_little_endian = True
+        ds.is_implicit_VR = False
+        ds.FloatPixelData = b'\x00\x01\x02\x03'
+        ds.save_as(fp)
+        assert fp.getvalue() == (
+            # Tag             | VR            | Length        | Value
+            b'\xe0\x7f\x08\x00\x4F\x46\x00\x00\x04\x00\x00\x00\x00\x01\x02\x03'
+        )
+
+
 class TestWritePN(object):
     """Test filewriter.write_PN"""
 
diff --git a/pydicom/tests/test_values.py b/pydicom/tests/test_values.py
--- a/pydicom/tests/test_values.py
+++ b/pydicom/tests/test_values.py
@@ -5,9 +5,10 @@
 import pytest
 
 from pydicom.tag import Tag
-from pydicom.values import (convert_value, converters, convert_tag,
-                            convert_ATvalue, convert_DA_string, convert_text,
-                            convert_single_string, convert_AE_string)
+from pydicom.values import (
+    convert_value, converters, convert_tag, convert_ATvalue, convert_DA_string,
+    convert_text, convert_single_string, convert_AE_string
+)
 
 
 class TestConvertTag(object):
@@ -188,3 +189,11 @@ def test_convert_value_raises(self):
         # Fix converters
         converters['PN'] = converter_func
         assert 'PN' in converters
+
+
+class TestConvertOValues(object):
+    """Test converting values with the 'O' VRs like OB, OW, OF, etc."""
+    def test_convert_of(self):
+        """Test converting OF."""
+        fp = b'\x00\x01\x02\x03'
+        assert b'\x00\x01\x02\x03' == converters['OF'](fp, True)

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_filereader.py pydicom/tests/test_filewriter.py pydicom/tests/test_values.py
: '>>>>> End Test Output'
git checkout caf0db105ddf389ff5025937fd5f3aa1e61e85e7 pydicom/tests/test_filereader.py pydicom/tests/test_filewriter.py pydicom/tests/test_values.py
