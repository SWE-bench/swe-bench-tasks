#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 7d0889e7143f5d4773fa74606efa816ed4e54c9f
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 7d0889e7143f5d4773fa74606efa816ed4e54c9f pydicom/tests/test_filereader.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_filereader.py b/pydicom/tests/test_filereader.py
--- a/pydicom/tests/test_filereader.py
+++ b/pydicom/tests/test_filereader.py
@@ -672,6 +672,14 @@ def test_no_dataset(self):
         self.assertEqual(ds.file_meta, Dataset())
         self.assertEqual(ds[:], Dataset())
 
+    def test_empty_file(self):
+        """Test reading no elements from file produces empty Dataset"""
+        with tempfile.NamedTemporaryFile() as f:
+            ds = dcmread(f, force=True)
+            self.assertTrue(ds.preamble is None)
+            self.assertEqual(ds.file_meta, Dataset())
+            self.assertEqual(ds[:], Dataset())
+
     def test_dcmread_does_not_raise(self):
         """Test that reading from DicomBytesIO does not raise on EOF.
         Regression test for #358."""

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_filereader.py
: '>>>>> End Test Output'
git checkout 7d0889e7143f5d4773fa74606efa816ed4e54c9f pydicom/tests/test_filereader.py
