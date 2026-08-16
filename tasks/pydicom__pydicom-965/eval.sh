#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff ee775c8a137cd8e0b69b46dc24c23648c31fe34c
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout ee775c8a137cd8e0b69b46dc24c23648c31fe34c pydicom/tests/test_dataelem.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_dataelem.py b/pydicom/tests/test_dataelem.py
--- a/pydicom/tests/test_dataelem.py
+++ b/pydicom/tests/test_dataelem.py
@@ -503,6 +503,23 @@ def check_empty_binary_element(value):
             check_empty_binary_element(MultiValue(int, []))
             check_empty_binary_element(None)
 
+    def test_empty_sequence_is_handled_as_array(self):
+        ds = Dataset()
+        ds.AcquisitionContextSequence = []
+        elem = ds['AcquisitionContextSequence']
+        assert bool(elem.value) is False
+        assert 0 == elem.VM
+        assert elem.value == []
+
+        fp = DicomBytesIO()
+        fp.is_little_endian = True
+        fp.is_implicit_VR = True
+        filewriter.write_dataset(fp, ds)
+        ds_read = dcmread(fp, force=True)
+        elem = ds_read['AcquisitionContextSequence']
+        assert 0 == elem.VM
+        assert elem.value == []
+
 
 class TestRawDataElement(object):
     """Tests for dataelem.RawDataElement."""

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_dataelem.py
: '>>>>> End Test Output'
git checkout ee775c8a137cd8e0b69b46dc24c23648c31fe34c pydicom/tests/test_dataelem.py
