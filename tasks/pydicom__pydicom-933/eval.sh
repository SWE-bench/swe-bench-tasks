#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 38436b6824c079564b8760ea6acfa4c0fd3ee9c3
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 38436b6824c079564b8760ea6acfa4c0fd3ee9c3 pydicom/tests/test_filereader.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_filereader.py b/pydicom/tests/test_filereader.py
--- a/pydicom/tests/test_filereader.py
+++ b/pydicom/tests/test_filereader.py
@@ -3,6 +3,7 @@
 """Unit tests for the pydicom.filereader module."""
 
 import gzip
+import io
 from io import BytesIO
 import os
 import shutil
@@ -918,6 +919,14 @@ def test_zipped_deferred(self):
         # the right place, it was re-opened as a normal file, not a zip file
         ds.InstanceNumber
 
+    def test_filelike_deferred(self):
+        """Deferred values work with file-like objects."""
+        with open(ct_name, 'rb') as fp:
+            data = fp.read()
+        filelike = io.BytesIO(data)
+        dataset = pydicom.dcmread(filelike, defer_size=1024)
+        assert 32768 == len(dataset.PixelData)
+
 
 class TestReadTruncatedFile(object):
     def testReadFileWithMissingPixelData(self):

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_filereader.py
: '>>>>> End Test Output'
git checkout 38436b6824c079564b8760ea6acfa4c0fd3ee9c3 pydicom/tests/test_filereader.py
