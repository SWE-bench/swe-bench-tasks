#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff e1a035a88fe36d466579b2f3940bde5b8b1bc84d
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout e1a035a88fe36d466579b2f3940bde5b8b1bc84d pydicom/tests/test_dictionary.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_dictionary.py b/pydicom/tests/test_dictionary.py
--- a/pydicom/tests/test_dictionary.py
+++ b/pydicom/tests/test_dictionary.py
@@ -30,6 +30,8 @@ def test_dict_has_tag(self):
         """Test dictionary_has_tag"""
         assert dictionary_has_tag(0x00100010)
         assert not dictionary_has_tag(0x11110010)
+        assert dictionary_has_tag("PatientName")
+        assert not dictionary_has_tag("PatientMane")
 
     def test_repeater_has_tag(self):
         """Test repeater_has_tag"""

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_dictionary.py
: '>>>>> End Test Output'
git checkout e1a035a88fe36d466579b2f3940bde5b8b1bc84d pydicom/tests/test_dictionary.py
