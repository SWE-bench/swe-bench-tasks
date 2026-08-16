#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff b9ee9b9c0625d737dfd4a60e9ed10609e7e0b7fd
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout b9ee9b9c0625d737dfd4a60e9ed10609e7e0b7fd tests/test_grid.py tests/test_polydata.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_grid.py b/tests/test_grid.py
--- a/tests/test_grid.py
+++ b/tests/test_grid.py
@@ -146,6 +146,14 @@ def test_init_from_arrays(specify_offset):
     assert np.allclose(cells, grid.cells)
     assert np.allclose(grid.cell_connectivity, np.arange(16))
 
+    # grid.cells is not mutable
+    assert not grid.cells.flags['WRITEABLE']
+
+    # but attribute can be set
+    new_cells = [8, 0, 1, 2, 3, 4, 5, 6, 7]
+    grid.cells = [8, 0, 1, 2, 3, 4, 5, 6, 7]
+    assert np.allclose(grid.cells, new_cells)
+
 
 @pytest.mark.parametrize('multiple_cell_types', [False, True])
 @pytest.mark.parametrize('flat_cells', [False, True])
diff --git a/tests/test_polydata.py b/tests/test_polydata.py
--- a/tests/test_polydata.py
+++ b/tests/test_polydata.py
@@ -82,6 +82,15 @@ def test_init_from_arrays():
     with pytest.warns(Warning):
         mesh = pyvista.PolyData(vertices.astype(np.int32), faces)
 
+    # array must be immutable
+    with pytest.raises(ValueError):
+        mesh.faces[0] += 1
+
+    # attribute is mutable
+    faces = [4, 0, 1, 2, 3]
+    mesh.faces = faces
+    assert np.allclose(faces, mesh.faces)
+
 
 def test_init_from_arrays_with_vert():
     vertices = np.array([[0, 0, 0], [1, 0, 0], [1, 1, 0], [0, 1, 0], [0.5, 0.5, -1], [0, 1.5, 1.5]])

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/test_grid.py tests/test_polydata.py
: '>>>>> End Test Output'
git checkout b9ee9b9c0625d737dfd4a60e9ed10609e7e0b7fd tests/test_grid.py tests/test_polydata.py
