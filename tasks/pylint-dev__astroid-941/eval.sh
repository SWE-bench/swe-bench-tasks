#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 962becc0ae86c16f7b33140f43cd6ed8f1e8a045
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 962becc0ae86c16f7b33140f43cd6ed8f1e8a045 tests/unittest_scoped_nodes.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/unittest_scoped_nodes.py b/tests/unittest_scoped_nodes.py
--- a/tests/unittest_scoped_nodes.py
+++ b/tests/unittest_scoped_nodes.py
@@ -1923,6 +1923,153 @@ def update(self):
         builder.parse(data)
 
 
+def test_issue940_metaclass_subclass_property():
+    node = builder.extract_node(
+        """
+    class BaseMeta(type):
+        @property
+        def __members__(cls):
+            return ['a', 'property']
+    class Parent(metaclass=BaseMeta):
+        pass
+    class Derived(Parent):
+        pass
+    Derived.__members__
+    """
+    )
+    inferred = next(node.infer())
+    assert isinstance(inferred, nodes.List)
+    assert [c.value for c in inferred.elts] == ["a", "property"]
+
+
+def test_issue940_property_grandchild():
+    node = builder.extract_node(
+        """
+    class Grandparent:
+        @property
+        def __members__(self):
+            return ['a', 'property']
+    class Parent(Grandparent):
+        pass
+    class Child(Parent):
+        pass
+    Child().__members__
+    """
+    )
+    inferred = next(node.infer())
+    assert isinstance(inferred, nodes.List)
+    assert [c.value for c in inferred.elts] == ["a", "property"]
+
+
+def test_issue940_metaclass_property():
+    node = builder.extract_node(
+        """
+    class BaseMeta(type):
+        @property
+        def __members__(cls):
+            return ['a', 'property']
+    class Parent(metaclass=BaseMeta):
+        pass
+    Parent.__members__
+    """
+    )
+    inferred = next(node.infer())
+    assert isinstance(inferred, nodes.List)
+    assert [c.value for c in inferred.elts] == ["a", "property"]
+
+
+def test_issue940_with_metaclass_class_context_property():
+    node = builder.extract_node(
+        """
+    class BaseMeta(type):
+        pass
+    class Parent(metaclass=BaseMeta):
+        @property
+        def __members__(self):
+            return ['a', 'property']
+    class Derived(Parent):
+        pass
+    Derived.__members__
+    """
+    )
+    inferred = next(node.infer())
+    assert not isinstance(inferred, nodes.List)
+    assert isinstance(inferred, objects.Property)
+
+
+def test_issue940_metaclass_values_funcdef():
+    node = builder.extract_node(
+        """
+    class BaseMeta(type):
+        def __members__(cls):
+            return ['a', 'func']
+    class Parent(metaclass=BaseMeta):
+        pass
+    Parent.__members__()
+    """
+    )
+    inferred = next(node.infer())
+    assert isinstance(inferred, nodes.List)
+    assert [c.value for c in inferred.elts] == ["a", "func"]
+
+
+def test_issue940_metaclass_derived_funcdef():
+    node = builder.extract_node(
+        """
+    class BaseMeta(type):
+        def __members__(cls):
+            return ['a', 'func']
+    class Parent(metaclass=BaseMeta):
+        pass
+    class Derived(Parent):
+        pass
+    Derived.__members__()
+    """
+    )
+    inferred_result = next(node.infer())
+    assert isinstance(inferred_result, nodes.List)
+    assert [c.value for c in inferred_result.elts] == ["a", "func"]
+
+
+def test_issue940_metaclass_funcdef_is_not_datadescriptor():
+    node = builder.extract_node(
+        """
+    class BaseMeta(type):
+        def __members__(cls):
+            return ['a', 'property']
+    class Parent(metaclass=BaseMeta):
+        @property
+        def __members__(cls):
+            return BaseMeta.__members__()
+    class Derived(Parent):
+        pass
+    Derived.__members__
+    """
+    )
+    # Here the function is defined on the metaclass, but the property
+    # is defined on the base class. When loading the attribute in a
+    # class context, this should return the property object instead of
+    # resolving the data descriptor
+    inferred = next(node.infer())
+    assert isinstance(inferred, objects.Property)
+
+
+def test_issue940_enums_as_a_real_world_usecase():
+    node = builder.extract_node(
+        """
+    from enum import Enum
+    class Sounds(Enum):
+        bee = "buzz"
+        cat = "meow"
+    Sounds.__members__
+    """
+    )
+    inferred_result = next(node.infer())
+    assert isinstance(inferred_result, nodes.Dict)
+    actual = [k.value for k, _ in inferred_result.items]
+    assert sorted(actual) == ["bee", "cat"]
+
+
 def test_metaclass_cannot_infer_call_yields_an_instance():
     node = builder.extract_node(
         """

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/unittest_scoped_nodes.py
: '>>>>> End Test Output'
git checkout 962becc0ae86c16f7b33140f43cd6ed8f1e8a045 tests/unittest_scoped_nodes.py
