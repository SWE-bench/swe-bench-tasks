#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff d804a93a3bcae250c74a9f0f7c37fbc8bf002011
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout d804a93a3bcae250c74a9f0f7c37fbc8bf002011 tests/filters/test_dataset_filters.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/filters/test_dataset_filters.py b/tests/filters/test_dataset_filters.py
--- a/tests/filters/test_dataset_filters.py
+++ b/tests/filters/test_dataset_filters.py
@@ -11,7 +11,7 @@
 from pyvista.core import _vtk_core
 from pyvista.core.celltype import CellType
 from pyvista.core.errors import NotAllTrianglesError, VTKVersionError
-from pyvista.errors import MissingDataError
+from pyvista.errors import MissingDataError, PyVistaDeprecationWarning
 
 normals = ['x', 'y', '-z', (1, 1, 1), (3.3, 5.4, 0.8)]
 
@@ -1145,17 +1145,24 @@ def test_smooth_taubin(uniform):
     assert np.allclose(smooth_inplace.points, smoothed.points)
 
 
-def test_resample():
+def test_sample():
     mesh = pyvista.Sphere(center=(4.5, 4.5, 4.5), radius=4.5)
     data_to_probe = examples.load_uniform()
-    result = mesh.sample(data_to_probe, progress_bar=True)
-    name = 'Spatial Point Data'
-    assert name in result.array_names
-    assert isinstance(result, type(mesh))
-    result = mesh.sample(data_to_probe, tolerance=1.0, progress_bar=True)
-    name = 'Spatial Point Data'
-    assert name in result.array_names
-    assert isinstance(result, type(mesh))
+
+    def sample_test(**kwargs):
+        """Test `sample` with kwargs."""
+        result = mesh.sample(data_to_probe, **kwargs)
+        name = 'Spatial Point Data'
+        assert name in result.array_names
+        assert isinstance(result, type(mesh))
+
+    sample_test()
+    sample_test(tolerance=1.0)
+    sample_test(progress_bar=True)
+    sample_test(categorical=True)
+    sample_test(locator=_vtk_core.vtkStaticCellLocator())
+    sample_test(pass_cell_data=False)
+    sample_test(pass_point_data=False)
 
 
 @pytest.mark.parametrize('use_points', [True, False])
@@ -1168,9 +1175,10 @@ def test_probe(categorical, use_points, locator):
         dataset = np.array(mesh.points)
     else:
         dataset = mesh
-    result = data_to_probe.probe(
-        dataset, tolerance=1e-5, categorical=categorical, progress_bar=True, locator=locator
-    )
+    with pytest.warns(PyVistaDeprecationWarning):
+        result = data_to_probe.probe(
+            dataset, tolerance=1e-5, categorical=categorical, progress_bar=True, locator=locator
+        )
     name = 'Spatial Point Data'
     assert name in result.array_names
     assert isinstance(result, type(mesh))

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/filters/test_dataset_filters.py
: '>>>>> End Test Output'
git checkout d804a93a3bcae250c74a9f0f7c37fbc8bf002011 tests/filters/test_dataset_filters.py
