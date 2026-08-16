#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 30ac743bcaedbc06f0e0d5cef590cb173756eb2d
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 30ac743bcaedbc06f0e0d5cef590cb173756eb2d pydicom/tests/test_handler_util.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_handler_util.py b/pydicom/tests/test_handler_util.py
--- a/pydicom/tests/test_handler_util.py
+++ b/pydicom/tests/test_handler_util.py
@@ -1150,6 +1150,15 @@ def test_first_map_negative(self):
         assert [60160, 25600, 37376] == list(rgb[arr == 130][0])
         assert ([60160, 25600, 37376] == rgb[arr == 130]).all()
 
+    def test_unchanged(self):
+        """Test dataset with no LUT is unchanged."""
+        # Regression test for #1068
+        ds = dcmread(MOD_16, force=True)
+        assert 'RedPaletteColorLookupTableDescriptor' not in ds
+        msg = r"No suitable Palette Color Lookup Table Module found"
+        with pytest.raises(ValueError, match=msg):
+            apply_color_lut(ds.pixel_array, ds)
+
 
 @pytest.mark.skipif(not HAVE_NP, reason="Numpy is not available")
 class TestNumpy_ExpandSegmentedLUT(object):

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_handler_util.py
: '>>>>> End Test Output'
git checkout 30ac743bcaedbc06f0e0d5cef590cb173756eb2d pydicom/tests/test_handler_util.py
