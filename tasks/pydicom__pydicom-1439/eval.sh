#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 506ecea8f378dc687d5c504788fc78810a190b7a
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 506ecea8f378dc687d5c504788fc78810a190b7a pydicom/tests/test_rle_pixel_data.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_rle_pixel_data.py b/pydicom/tests/test_rle_pixel_data.py
--- a/pydicom/tests/test_rle_pixel_data.py
+++ b/pydicom/tests/test_rle_pixel_data.py
@@ -881,11 +881,10 @@ def test_invalid_nr_segments_raises(self, header, samples, bits):
                 header, rows=1, columns=1, nr_samples=samples, nr_bits=bits
             )
 
-    def test_invalid_frame_data_raises(self):
-        """Test that invalid segment data raises exception."""
+    def test_invalid_segment_data_raises(self):
+        """Test invalid segment data raises exception"""
         ds = dcmread(RLE_16_1_1F)
         pixel_data = defragment_data(ds.PixelData)
-        # Missing byte
         msg = r"amount \(4095 vs. 4096 bytes\)"
         with pytest.raises(ValueError, match=msg):
             _rle_decode_frame(
@@ -896,13 +895,19 @@ def test_invalid_frame_data_raises(self):
                 ds.BitsAllocated
             )
 
-        # Extra byte
-        msg = r'amount \(4097 vs. 4096 bytes\)'
-        with pytest.raises(ValueError, match=msg):
-            _rle_decode_frame(
+    def test_nonconf_segment_padding_warns(self):
+        """Test non-conformant segment padding warns"""
+        ds = dcmread(RLE_16_1_1F)
+        pixel_data = defragment_data(ds.PixelData)
+        msg = (
+            r"The decoded RLE segment contains non-conformant padding - 4097 "
+            r"vs. 4096 bytes expected"
+        )
+        with pytest.warns(UserWarning, match=msg):
+            frame = _rle_decode_frame(
                 pixel_data + b'\x00\x01',
-                ds.Rows,
-                ds.Columns,
+                4096,
+                1,
                 ds.SamplesPerPixel,
                 ds.BitsAllocated
             )

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_rle_pixel_data.py
: '>>>>> End Test Output'
git checkout 506ecea8f378dc687d5c504788fc78810a190b7a pydicom/tests/test_rle_pixel_data.py
