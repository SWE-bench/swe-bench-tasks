#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff d0c2e12cac39af1872b00907f9526dbfb59ec69e
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout d0c2e12cac39af1872b00907f9526dbfb59ec69e tests/core/test_polydata.py tests/core/test_polydata_filters.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/core/test_polydata.py b/tests/core/test_polydata.py
--- a/tests/core/test_polydata.py
+++ b/tests/core/test_polydata.py
@@ -280,9 +280,9 @@ def test_boolean_difference(sphere, sphere_shifted):
     assert np.isclose(difference.volume, expected_volume, atol=1e-3)
 
 
-def test_boolean_difference_fail(plane):
+def test_boolean_difference_fail(plane, sphere):
     with pytest.raises(NotAllTrianglesError):
-        plane - plane
+        plane - sphere
 
 
 def test_subtract(sphere, sphere_shifted):
diff --git a/tests/core/test_polydata_filters.py b/tests/core/test_polydata_filters.py
--- a/tests/core/test_polydata_filters.py
+++ b/tests/core/test_polydata_filters.py
@@ -45,3 +45,8 @@ def test_boolean_intersect_edge_case():
 
     with pytest.warns(UserWarning, match='contained within another'):
         a.boolean_intersection(b)
+
+
+def test_identical_boolean(sphere):
+    with pytest.raises(ValueError, match='identical points'):
+        sphere.boolean_intersection(sphere.copy())

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/core/test_polydata.py tests/core/test_polydata_filters.py
: '>>>>> End Test Output'
git checkout d0c2e12cac39af1872b00907f9526dbfb59ec69e tests/core/test_polydata.py tests/core/test_polydata_filters.py
