#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 23d0551569d748460c504af85996451edd685371
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e '.[dev]'
git checkout 23d0551569d748460c504af85996451edd685371 tests/test_fields.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_fields.py b/tests/test_fields.py
--- a/tests/test_fields.py
+++ b/tests/test_fields.py
@@ -187,6 +187,14 @@ class Meta:
         for field_name in ("bar", "qux"):
             assert schema.fields[field_name].tuple_fields[0].format == "iso8601"
 
+    # Regression test for https://github.com/marshmallow-code/marshmallow/issues/1808
+    def test_field_named_parent_has_root(self, schema):
+        class MySchema(Schema):
+            parent = fields.Field()
+
+        schema = MySchema()
+        assert schema.fields["parent"].root == schema
+
 
 class TestMetadata:
     @pytest.mark.parametrize("FieldClass", ALL_FIELDS)

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/test_fields.py
: '>>>>> End Test Output'
git checkout 23d0551569d748460c504af85996451edd685371 tests/test_fields.py
