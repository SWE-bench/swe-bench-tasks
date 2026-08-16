#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff fa6c7379468f59d4568e29cbbeb06b797d656215
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e '.[dev]'
git checkout fa6c7379468f59d4568e29cbbeb06b797d656215 tests/test_fields.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_fields.py b/tests/test_fields.py
--- a/tests/test_fields.py
+++ b/tests/test_fields.py
@@ -197,11 +197,27 @@ def test_extra_metadata_may_be_added_to_field(self, FieldClass):  # noqa
             required=True,
             default=None,
             validate=lambda v: True,
-            description="foo",
-            widget="select",
+            metadata={"description": "foo", "widget": "select"},
         )
         assert field.metadata == {"description": "foo", "widget": "select"}
 
+    @pytest.mark.parametrize("FieldClass", ALL_FIELDS)
+    def test_field_metadata_added_in_deprecated_style_warns(self, FieldClass):  # noqa
+        # just the old style
+        with pytest.warns(DeprecationWarning):
+            field = FieldClass(description="Just a normal field.")
+            assert field.metadata["description"] == "Just a normal field."
+        # mixed styles
+        with pytest.warns(DeprecationWarning):
+            field = FieldClass(
+                required=True,
+                default=None,
+                validate=lambda v: True,
+                description="foo",
+                metadata={"widget": "select"},
+            )
+        assert field.metadata == {"description": "foo", "widget": "select"}
+
 
 class TestErrorMessages:
     class MyField(fields.Field):

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/test_fields.py
: '>>>>> End Test Output'
git checkout fa6c7379468f59d4568e29cbbeb06b797d656215 tests/test_fields.py
