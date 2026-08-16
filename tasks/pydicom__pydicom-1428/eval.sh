#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 674da68db47a71ee6929288a047b56cf31cf8168
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 674da68db47a71ee6929288a047b56cf31cf8168 pydicom/tests/test_fileset.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_fileset.py b/pydicom/tests/test_fileset.py
--- a/pydicom/tests/test_fileset.py
+++ b/pydicom/tests/test_fileset.py
@@ -1945,33 +1945,45 @@ def test_find_load(self, private):
     def test_find_values(self, private):
         """Test searching the FileSet for element values."""
         fs = FileSet(private)
-        assert ['77654033', '98890234'] == fs.find_values("PatientID")
-        assert (
-            [
+        expected = {
+            "PatientID": ['77654033', '98890234'],
+            "StudyDescription": [
                 'XR C Spine Comp Min 4 Views',
                 'CT, HEAD/BRAIN WO CONTRAST',
                 '',
                 'Carotids',
                 'Brain',
-                'Brain-MRA'
-            ] == fs.find_values("StudyDescription")
-        )
+                'Brain-MRA',
+            ],
+        }
+        for k, v in expected.items():
+            assert fs.find_values(k) == v
+        assert fs.find_values(list(expected.keys())) == expected
 
     def test_find_values_load(self, private):
         """Test FileSet.find_values(load=True)."""
         fs = FileSet(private)
+        search_element = "PhotometricInterpretation"
         msg = (
             r"None of the records in the DICOMDIR dataset contain "
-            r"the query element, consider using the 'load' parameter "
+            fr"\['{search_element}'\], consider using the 'load' parameter "
             r"to expand the search to the corresponding SOP instances"
         )
         with pytest.warns(UserWarning, match=msg):
-            results = fs.find_values("PhotometricInterpretation", load=False)
+            results = fs.find_values(search_element, load=False)
             assert not results
 
-        assert ['MONOCHROME1', 'MONOCHROME2'] == fs.find_values(
-            "PhotometricInterpretation", load=True
-        )
+        assert fs.find_values(search_element, load=True) == [
+            'MONOCHROME1', 'MONOCHROME2'
+        ]
+
+        with pytest.warns(UserWarning, match=msg):
+            results = fs.find_values([search_element], load=False)
+            assert not results[search_element]
+
+        assert (
+            fs.find_values([search_element], load=True)
+        ) == {search_element: ['MONOCHROME1', 'MONOCHROME2']}
 
     def test_empty_file_id(self, dicomdir):
         """Test loading a record with an empty File ID."""

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_fileset.py
: '>>>>> End Test Output'
git checkout 674da68db47a71ee6929288a047b56cf31cf8168 pydicom/tests/test_fileset.py
