#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 9363c34934f94124f4867caf1bdf8f6755201ccd
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 9363c34934f94124f4867caf1bdf8f6755201ccd tests/unittest_scoped_nodes.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/unittest_scoped_nodes.py b/tests/unittest_scoped_nodes.py
--- a/tests/unittest_scoped_nodes.py
+++ b/tests/unittest_scoped_nodes.py
@@ -43,9 +43,9 @@
 
 import pytest
 
-from astroid import MANAGER, builder, nodes, objects, test_utils, util
+from astroid import MANAGER, builder, nodes, objects, parse, test_utils, util
 from astroid.bases import BoundMethod, Generator, Instance, UnboundMethod
-from astroid.const import PY38_PLUS
+from astroid.const import PY38_PLUS, PY310_PLUS, WIN32
 from astroid.exceptions import (
     AttributeInferenceError,
     DuplicateBasesError,
@@ -1670,6 +1670,49 @@ class B(A[T], A[T]): ...
         with self.assertRaises(DuplicateBasesError):
             cls.mro()
 
+    @test_utils.require_version(minver="3.7")
+    def test_mro_typing_extensions(self):
+        """Regression test for mro() inference on typing_extesnions.
+
+        Regression reported in:
+        https://github.com/PyCQA/astroid/issues/1124
+        """
+        module = parse(
+            """
+        import abc
+        import typing
+        import dataclasses
+
+        import typing_extensions
+
+        T = typing.TypeVar("T")
+
+        class MyProtocol(typing_extensions.Protocol): pass
+        class EarlyBase(typing.Generic[T], MyProtocol): pass
+        class Base(EarlyBase[T], abc.ABC): pass
+        class Final(Base[object]): pass
+        """
+        )
+        class_names = [
+            "ABC",
+            "Base",
+            "EarlyBase",
+            "Final",
+            "Generic",
+            "MyProtocol",
+            "Protocol",
+            "object",
+        ]
+        if not PY38_PLUS:
+            class_names.pop(-2)
+        # typing_extensions is not installed on this combination of version
+        # and platform
+        if PY310_PLUS and WIN32:
+            class_names.pop(-2)
+
+        final_def = module.body[-1]
+        self.assertEqual(class_names, sorted(i.name for i in final_def.mro()))
+
     def test_generator_from_infer_call_result_parent(self) -> None:
         func = builder.extract_node(
             """

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/unittest_scoped_nodes.py
: '>>>>> End Test Output'
git checkout 9363c34934f94124f4867caf1bdf8f6755201ccd tests/unittest_scoped_nodes.py
