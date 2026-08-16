#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff a8921b94b91a7d9809c9b5ac2ef9c981b5f71ea1
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout a8921b94b91a7d9809c9b5ac2ef9c981b5f71ea1 tests/test_composite.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_composite.py b/tests/test_composite.py
--- a/tests/test_composite.py
+++ b/tests/test_composite.py
@@ -753,9 +753,13 @@ def test_set_active_scalars_mixed(multiblock_poly):
 
 
 def test_to_polydata(multiblock_all):
+    if pyvista.vtk_version_info >= (9, 1, 0):
+        multiblock_all.append(pyvista.PointSet([0.0, 0.0, 1.0]))  # missing pointset
     assert not multiblock_all.is_all_polydata
 
     dataset_a = multiblock_all.as_polydata_blocks()
+    if pyvista.vtk_version_info >= (9, 1, 0):
+        assert dataset_a[-1].n_points == 1
     assert not multiblock_all.is_all_polydata
     assert dataset_a.is_all_polydata
 

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/test_composite.py
: '>>>>> End Test Output'
git checkout a8921b94b91a7d9809c9b5ac2ef9c981b5f71ea1 tests/test_composite.py
