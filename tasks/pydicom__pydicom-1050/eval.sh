#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 00c248441ffb8b7d46c6d855b723e696a8f5aada
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 00c248441ffb8b7d46c6d855b723e696a8f5aada pydicom/tests/test_filereader.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_filereader.py b/pydicom/tests/test_filereader.py
--- a/pydicom/tests/test_filereader.py
+++ b/pydicom/tests/test_filereader.py
@@ -674,6 +674,27 @@ def test_lut_descriptor(self):
             assert elem.VR == 'SS'
             assert elem.value == [62720, -2048, 16]
 
+    def test_lut_descriptor_empty(self):
+        """Regression test for #1049: LUT empty raises."""
+        bs = DicomBytesIO(b'\x28\x00\x01\x11\x53\x53\x00\x00')
+        bs.is_little_endian = True
+        bs.is_implicit_VR = False
+        ds = dcmread(bs, force=True)
+        elem = ds[0x00281101]
+        assert elem.value is None
+        assert elem.VR == 'SS'
+
+    def test_lut_descriptor_singleton(self):
+        """Test LUT Descriptor with VM = 1"""
+        bs = DicomBytesIO(b'\x28\x00\x01\x11\x53\x53\x02\x00\x00\xf5')
+        bs.is_little_endian = True
+        bs.is_implicit_VR = False
+        ds = dcmread(bs, force=True)
+        elem = ds[0x00281101]
+        # No conversion to US if not a triplet
+        assert elem.value == -2816
+        assert elem.VR == 'SS'
+
 
 class TestIncorrectVR(object):
     def setup(self):

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_filereader.py
: '>>>>> End Test Output'
git checkout 00c248441ffb8b7d46c6d855b723e696a8f5aada pydicom/tests/test_filereader.py
