#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 8112bb69bfc0423c3a08cb89e7960defbe7237bf
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 8112bb69bfc0423c3a08cb89e7960defbe7237bf pydicom/tests/test_json.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_json.py b/pydicom/tests/test_json.py
--- a/pydicom/tests/test_json.py
+++ b/pydicom/tests/test_json.py
@@ -334,7 +334,18 @@ def test_invalid_bulkdata_uri(self):
             Dataset.from_json(ds_json)
 
     def test_bulk_data_reader_is_called(self):
-        def bulk_data_reader(_):
+        def bulk_data_reader(value):
+            return b'xyzzy'
+
+        json_data = {
+            "00091002": {"vr": "OB", "BulkDataURI": "https://a.dummy.url"}
+        }
+        ds = Dataset().from_json(json.dumps(json_data), bulk_data_reader)
+
+        assert b'xyzzy' == ds[0x00091002].value
+
+    def test_bulk_data_reader_is_called_2(self):
+        def bulk_data_reader(tag, vr, value):
             return b'xyzzy'
 
         json_data = {

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_json.py
: '>>>>> End Test Output'
git checkout 8112bb69bfc0423c3a08cb89e7960defbe7237bf pydicom/tests/test_json.py
