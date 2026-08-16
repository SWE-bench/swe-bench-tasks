#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 456bacbbead4fa30a1a82892c9446ac9efb8055b
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e '.[dev]'
git checkout 456bacbbead4fa30a1a82892c9446ac9efb8055b tests/test_fields.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_fields.py b/tests/test_fields.py
--- a/tests/test_fields.py
+++ b/tests/test_fields.py
@@ -247,6 +247,36 @@ class MySchema(Schema):
 
 class TestListNested:
 
+    @pytest.mark.parametrize('param', ('only', 'exclude', 'dump_only', 'load_only'))
+    def test_list_nested_only_exclude_dump_only_load_only_propagated_to_nested(self, param):
+
+        class Child(Schema):
+            name = fields.String()
+            age = fields.Integer()
+
+        class Family(Schema):
+            children = fields.List(fields.Nested(Child))
+
+        schema = Family(**{param: ['children.name']})
+        assert getattr(schema.fields['children'].container.schema, param) == {'name'}
+
+    @pytest.mark.parametrize(
+        ('param', 'expected'),
+        (('only', {'name'}), ('exclude', {'name', 'surname', 'age'})),
+    )
+    def test_list_nested_only_and_exclude_merged_with_nested(self, param, expected):
+
+        class Child(Schema):
+            name = fields.String()
+            surname = fields.String()
+            age = fields.Integer()
+
+        class Family(Schema):
+            children = fields.List(fields.Nested(Child, **{param: ('name', 'surname')}))
+
+        schema = Family(**{param: ['children.name', 'children.age']})
+        assert getattr(schema.fields['children'].container, param) == expected
+
     def test_list_nested_partial_propagated_to_nested(self):
 
         class Child(Schema):
@@ -279,6 +309,20 @@ class Family(Schema):
 
 class TestTupleNested:
 
+    @pytest.mark.parametrize('param', ('dump_only', 'load_only'))
+    def test_tuple_nested_only_exclude_dump_only_load_only_propagated_to_nested(self, param):
+
+        class Child(Schema):
+            name = fields.String()
+            age = fields.Integer()
+
+        class Family(Schema):
+            children = fields.Tuple((fields.Nested(Child), fields.Nested(Child)))
+
+        schema = Family(**{param: ['children.name']})
+        assert getattr(schema.fields['children'].tuple_fields[0].schema, param) == {'name'}
+        assert getattr(schema.fields['children'].tuple_fields[1].schema, param) == {'name'}
+
     def test_tuple_nested_partial_propagated_to_nested(self):
 
         class Child(Schema):
@@ -311,6 +355,36 @@ class Family(Schema):
 
 class TestDictNested:
 
+    @pytest.mark.parametrize('param', ('only', 'exclude', 'dump_only', 'load_only'))
+    def test_dict_nested_only_exclude_dump_only_load_only_propagated_to_nested(self, param):
+
+        class Child(Schema):
+            name = fields.String()
+            age = fields.Integer()
+
+        class Family(Schema):
+            children = fields.Dict(values=fields.Nested(Child))
+
+        schema = Family(**{param: ['children.name']})
+        assert getattr(schema.fields['children'].value_container.schema, param) == {'name'}
+
+    @pytest.mark.parametrize(
+        ('param', 'expected'),
+        (('only', {'name'}), ('exclude', {'name', 'surname', 'age'})),
+    )
+    def test_dict_nested_only_and_exclude_merged_with_nested(self, param, expected):
+
+        class Child(Schema):
+            name = fields.String()
+            surname = fields.String()
+            age = fields.Integer()
+
+        class Family(Schema):
+            children = fields.Dict(values=fields.Nested(Child, **{param: ('name', 'surname')}))
+
+        schema = Family(**{param: ['children.name', 'children.age']})
+        assert getattr(schema.fields['children'].value_container, param) == expected
+
     def test_dict_nested_partial_propagated_to_nested(self):
 
         class Child(Schema):

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/test_fields.py
: '>>>>> End Test Output'
git checkout 456bacbbead4fa30a1a82892c9446ac9efb8055b tests/test_fields.py
