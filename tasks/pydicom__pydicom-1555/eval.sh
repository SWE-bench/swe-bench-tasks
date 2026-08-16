#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 9db89e1d8f5e82dc617f9c8cbf303fe23a0632b9
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 9db89e1d8f5e82dc617f9c8cbf303fe23a0632b9 pydicom/tests/test_handler_util.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_handler_util.py b/pydicom/tests/test_handler_util.py
--- a/pydicom/tests/test_handler_util.py
+++ b/pydicom/tests/test_handler_util.py
@@ -890,6 +890,10 @@ def test_unchanged(self):
         out = apply_modality_lut(arr, ds)
         assert arr is out
 
+        ds.ModalityLUTSequence = []
+        out = apply_modality_lut(arr, ds)
+        assert arr is out
+
     def test_lutdata_ow(self):
         """Test LUT Data with VR OW."""
         ds = dcmread(MOD_16_SEQ)
@@ -1839,6 +1843,10 @@ def test_unchanged(self):
         out = apply_windowing(arr, ds)
         assert [-128, -127, -1, 0, 1, 126, 127] == out.tolist()
 
+        ds.ModalityLUTSequence = []
+        out = apply_windowing(arr, ds)
+        assert [-128, -127, -1, 0, 1, 126, 127] == out.tolist()
+
     def test_rescale_empty(self):
         """Test RescaleSlope and RescaleIntercept being empty."""
         ds = dcmread(WIN_12_1F)
@@ -2051,6 +2059,11 @@ def test_unchanged(self):
         out = apply_voi(arr, ds)
         assert [-128, -127, -1, 0, 1, 126, 127] == out.tolist()
 
+        ds.VOILUTSequence = []
+        out = apply_voi(arr, ds)
+        assert [-128, -127, -1, 0, 1, 126, 127] == out.tolist()
+
+
     def test_voi_lutdata_ow(self):
         """Test LUT Data with VR OW."""
         ds = Dataset()
@@ -2072,6 +2085,7 @@ def test_voi_lutdata_ow(self):
 
 @pytest.mark.skipif(not HAVE_NP, reason="Numpy is not available")
 class TestNumpy_ApplyVOILUT:
+    """Tests for util.apply_voi_lut()"""
     def test_unchanged(self):
         """Test input array is unchanged if no VOI LUT"""
         ds = Dataset()
@@ -2082,6 +2096,10 @@ def test_unchanged(self):
         out = apply_voi_lut(arr, ds)
         assert [-128, -127, -1, 0, 1, 126, 127] == out.tolist()
 
+        ds.VOILUTSequence = []
+        out = apply_voi_lut(arr, ds)
+        assert [-128, -127, -1, 0, 1, 126, 127] == out.tolist()
+
     def test_only_windowing(self):
         """Test only windowing operation elements present."""
         ds = Dataset()

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_handler_util.py
: '>>>>> End Test Output'
git checkout 9db89e1d8f5e82dc617f9c8cbf303fe23a0632b9 pydicom/tests/test_handler_util.py
