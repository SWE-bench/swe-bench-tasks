#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff e9fc645cd8e75d71f7835c0d6e3c0b94b22c2808
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout e9fc645cd8e75d71f7835c0d6e3c0b94b22c2808 pydicom/tests/test_fileset.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_fileset.py b/pydicom/tests/test_fileset.py
--- a/pydicom/tests/test_fileset.py
+++ b/pydicom/tests/test_fileset.py
@@ -2450,6 +2450,21 @@ def test_add_bad_one_level(self, dummy):
         with pytest.raises(ValueError, match=msg):
             fs.add(ds)
 
+    def test_write_undefined_length(self, dicomdir_copy):
+        """Test writing with undefined length items"""
+        t, ds = dicomdir_copy
+        elem = ds["DirectoryRecordSequence"]
+        ds["DirectoryRecordSequence"].is_undefined_length = True
+        for item in ds.DirectoryRecordSequence:
+            item.is_undefined_length_sequence_item = True
+
+        fs = FileSet(ds)
+        fs.write(use_existing=True)
+
+        ds = dcmread(Path(t.name) / "DICOMDIR")
+        item = ds.DirectoryRecordSequence[-1]
+        assert item.ReferencedFileID == ['98892003', 'MR700', '4648']
+
 
 @pytest.mark.filterwarnings("ignore:The 'DicomDir'")
 class TestFileSet_Copy:

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_fileset.py
: '>>>>> End Test Output'
git checkout e9fc645cd8e75d71f7835c0d6e3c0b94b22c2808 pydicom/tests/test_fileset.py
