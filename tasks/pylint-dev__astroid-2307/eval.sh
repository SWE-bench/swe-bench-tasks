#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 1113d490ec4a94cdc1b35f45abfdaca9f19fa31e
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 1113d490ec4a94cdc1b35f45abfdaca9f19fa31e tests/brain/test_typing.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/brain/test_typing.py b/tests/brain/test_typing.py
--- a/tests/brain/test_typing.py
+++ b/tests/brain/test_typing.py
@@ -2,7 +2,10 @@
 # For details: https://github.com/pylint-dev/astroid/blob/main/LICENSE
 # Copyright (c) https://github.com/pylint-dev/astroid/blob/main/CONTRIBUTORS.txt
 
-from astroid import builder, nodes
+import pytest
+
+from astroid import builder
+from astroid.exceptions import InferenceError
 
 
 def test_infer_typevar() -> None:
@@ -12,13 +15,11 @@ def test_infer_typevar() -> None:
     Test that an inferred `typing.TypeVar()` call produces a `nodes.ClassDef`
     node.
     """
-    assign_node = builder.extract_node(
+    call_node = builder.extract_node(
         """
     from typing import TypeVar
-    MyType = TypeVar('My.Type')
+    TypeVar('My.Type')
     """
     )
-    call = assign_node.value
-    inferred = next(call.infer())
-    assert isinstance(inferred, nodes.ClassDef)
-    assert inferred.name == "My.Type"
+    with pytest.raises(InferenceError):
+        call_node.inferred()

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/brain/test_typing.py
: '>>>>> End Test Output'
git checkout 1113d490ec4a94cdc1b35f45abfdaca9f19fa31e tests/brain/test_typing.py
