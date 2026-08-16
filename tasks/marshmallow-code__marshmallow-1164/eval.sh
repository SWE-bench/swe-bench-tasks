#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 1e26d14facab213df5009300b997481aa43df80a
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e '.[dev]'
git checkout 1e26d14facab213df5009300b997481aa43df80a tests/test_serialization.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_serialization.py b/tests/test_serialization.py
--- a/tests/test_serialization.py
+++ b/tests/test_serialization.py
@@ -782,3 +782,21 @@ class ValueSchema(Schema):
 
     serialized = ValueSchema(many=True).dump(slice).data
     assert serialized == values
+
+
+# https://github.com/marshmallow-code/marshmallow/issues/1163
+def test_nested_field_many_serializing_generator():
+    class MySchema(Schema):
+        name = fields.Str()
+
+    class OtherSchema(Schema):
+        objects = fields.Nested(MySchema, many=True)
+
+    def gen():
+        yield {'name': 'foo'}
+        yield {'name': 'bar'}
+
+    obj = {'objects': gen()}
+    data, _ = OtherSchema().dump(obj)
+
+    assert data.get('objects') == [{'name': 'foo'}, {'name': 'bar'}]

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/test_serialization.py
: '>>>>> End Test Output'
git checkout 1e26d14facab213df5009300b997481aa43df80a tests/test_serialization.py
