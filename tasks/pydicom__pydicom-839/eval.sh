#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff da9e0df8da28a35596f830379341a379de8ac439
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout da9e0df8da28a35596f830379341a379de8ac439 pydicom/tests/test_filewriter.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_filewriter.py b/pydicom/tests/test_filewriter.py
--- a/pydicom/tests/test_filewriter.py
+++ b/pydicom/tests/test_filewriter.py
@@ -671,9 +671,15 @@ def test_pixel_representation_vm_one(self):
         assert 1 == ds.SmallestValidPixelValue
         assert 'SS' == ds[0x00280104].VR
 
-        # If no PixelRepresentation AttributeError shall be raised
+        # If no PixelRepresentation and no PixelData is present 'US' is set
         ref_ds = Dataset()
         ref_ds.SmallestValidPixelValue = b'\x00\x01'  # Big endian 1
+        ds = correct_ambiguous_vr(deepcopy(ref_ds), True)
+        assert 'US' == ds[0x00280104].VR
+
+        # If no PixelRepresentation but PixelData is present
+        # AttributeError shall be raised
+        ref_ds.PixelData = b'123'
         with pytest.raises(AttributeError,
                            match=r"Failed to resolve ambiguous VR for tag "
                                  r"\(0028, 0104\):.* 'PixelRepresentation'"):
@@ -697,9 +703,14 @@ def test_pixel_representation_vm_three(self):
         assert [256, 1, 16] == ds.LUTDescriptor
         assert 'SS' == ds[0x00283002].VR
 
-        # If no PixelRepresentation AttributeError shall be raised
+        # If no PixelRepresentation and no PixelData is present 'US' is set
         ref_ds = Dataset()
         ref_ds.LUTDescriptor = b'\x01\x00\x00\x01\x00\x10'
+        ds = correct_ambiguous_vr(deepcopy(ref_ds), True)
+        assert 'US' == ds[0x00283002].VR
+
+        # If no PixelRepresentation AttributeError shall be raised
+        ref_ds.PixelData = b'123'
         with pytest.raises(AttributeError,
                            match=r"Failed to resolve ambiguous VR for tag "
                                  r"\(0028, 3002\):.* 'PixelRepresentation'"):
@@ -928,6 +939,13 @@ def test_correct_ambiguous_data_element(self):
         """Test correct ambiguous US/SS element"""
         ds = Dataset()
         ds.PixelPaddingValue = b'\xfe\xff'
+        out = correct_ambiguous_vr_element(ds[0x00280120], ds, True)
+        # assume US if PixelData is not set
+        assert 'US' == out.VR
+
+        ds = Dataset()
+        ds.PixelPaddingValue = b'\xfe\xff'
+        ds.PixelData = b'3456'
         with pytest.raises(AttributeError,
                            match=r"Failed to resolve ambiguous VR for tag "
                                  r"\(0028, 0120\):.* 'PixelRepresentation'"):

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_filewriter.py
: '>>>>> End Test Output'
git checkout da9e0df8da28a35596f830379341a379de8ac439 pydicom/tests/test_filewriter.py
