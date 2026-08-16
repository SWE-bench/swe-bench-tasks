#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff b4b44acbf1ddcaf03df16210aac46cb3a8acd6b9
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout b4b44acbf1ddcaf03df16210aac46cb3a8acd6b9 pydicom/tests/test_numpy_pixel_data.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_numpy_pixel_data.py b/pydicom/tests/test_numpy_pixel_data.py
--- a/pydicom/tests/test_numpy_pixel_data.py
+++ b/pydicom/tests/test_numpy_pixel_data.py
@@ -986,13 +986,23 @@ def test_bad_length_raises(self):
         # Too short
         ds.PixelData = ds.PixelData[:-1]
         msg = (
-            r"The length of the pixel data in the dataset doesn't match the "
-            r"expected amount \(479999 vs. 480000 bytes\). The dataset may be "
-            r"corrupted or there may be an issue with the pixel data handler."
+            r"The length of the pixel data in the dataset \(479999 bytes\) "
+            r"doesn't match the expected length \(480000 bytes\). "
+            r"The dataset may be corrupted or there may be an issue "
+            r"with the pixel data handler."
         )
         with pytest.raises(ValueError, match=msg):
             get_pixeldata(ds)
 
+    def test_missing_padding_warns(self):
+        """A warning shall be issued if the padding for odd data is missing."""
+        ds = dcmread(EXPL_8_3_1F_ODD)
+        # remove the padding byte
+        ds.PixelData = ds.PixelData[:-1]
+        msg = "The pixel data length is odd and misses a padding byte."
+        with pytest.warns(UserWarning, match=msg):
+            get_pixeldata(ds)
+
     def test_change_photometric_interpretation(self):
         """Test get_pixeldata changes PhotometricInterpretation if required."""
         def to_rgb(ds):

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_numpy_pixel_data.py
: '>>>>> End Test Output'
git checkout b4b44acbf1ddcaf03df16210aac46cb3a8acd6b9 pydicom/tests/test_numpy_pixel_data.py
