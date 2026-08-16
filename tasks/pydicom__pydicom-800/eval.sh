#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 2f3586b6f67383b1ec0c24c4772e65119c3f5261
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 2f3586b6f67383b1ec0c24c4772e65119c3f5261 pydicom/tests/test_uid.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_uid.py b/pydicom/tests/test_uid.py
--- a/pydicom/tests/test_uid.py
+++ b/pydicom/tests/test_uid.py
@@ -1,6 +1,8 @@
 # Copyright 2008-2018 pydicom authors. See LICENSE file for details.
 """Test suite for uid.py"""
 
+import uuid
+
 import pytest
 
 from pydicom.uid import UID, generate_uid, PYDICOM_ROOT_UID, JPEGLSLossy
@@ -57,6 +59,24 @@ def test_entropy_src_custom(self):
         assert uid == rf
         assert len(uid) == 64
 
+    def test_none(self):
+        """Test generate_uid(None)."""
+        uid = generate_uid(prefix=None)
+        # Check prefix
+        assert '2.25.' == uid[:5]
+        # Check UUID suffix
+        as_uuid = uuid.UUID(int=int(uid[5:]))
+        assert isinstance(as_uuid, uuid.UUID)
+        assert as_uuid.version == 4
+        assert as_uuid.variant == uuid.RFC_4122
+
+    def test_none_iterate(self):
+        """Test generate_uid(None) generates valid UIDs."""
+        # Generate random UIDs, if a bad method then should eventually fail
+        for ii in range(100000):
+            uid = generate_uid(None)
+            assert uid.is_valid
+
 
 class TestUID(object):
     """Test DICOM UIDs"""

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_uid.py
: '>>>>> End Test Output'
git checkout 2f3586b6f67383b1ec0c24c4772e65119c3f5261 pydicom/tests/test_uid.py
