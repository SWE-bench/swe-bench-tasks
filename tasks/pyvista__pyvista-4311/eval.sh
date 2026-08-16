#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff db6ee8dd4a747b8864caae36c5d05883976a3ae5
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout db6ee8dd4a747b8864caae36c5d05883976a3ae5 tests/filters/test_rectilinear_grid.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/filters/test_rectilinear_grid.py b/tests/filters/test_rectilinear_grid.py
--- a/tests/filters/test_rectilinear_grid.py
+++ b/tests/filters/test_rectilinear_grid.py
@@ -45,3 +45,25 @@ def test_to_tetrahedral_mixed(tiny_rectilinear):
 def test_to_tetrahedral_edge_case():
     with pytest.raises(RuntimeError, match='is 1'):
         pv.UniformGrid(dimensions=(1, 2, 2)).to_tetrahedra(tetra_per_cell=12)
+
+
+def test_to_tetrahedral_pass_cell_ids(tiny_rectilinear):
+    tet_grid = tiny_rectilinear.to_tetrahedra(pass_cell_ids=False, pass_cell_data=False)
+    assert not tet_grid.cell_data
+    tet_grid = tiny_rectilinear.to_tetrahedra(pass_cell_ids=True, pass_cell_data=False)
+    assert 'vtkOriginalCellIds' in tet_grid.cell_data
+    assert np.issubdtype(tet_grid.cell_data['vtkOriginalCellIds'].dtype, np.integer)
+
+
+def test_to_tetrahedral_pass_cell_data(tiny_rectilinear):
+    tiny_rectilinear["cell_data"] = np.ones(tiny_rectilinear.n_cells)
+
+    tet_grid = tiny_rectilinear.to_tetrahedra(pass_cell_ids=False, pass_cell_data=False)
+    assert not tet_grid.cell_data
+
+    tet_grid = tiny_rectilinear.to_tetrahedra(pass_cell_ids=False, pass_cell_data=True)
+    assert tet_grid.cell_data
+    assert "cell_data" in tet_grid.cell_data
+
+    # automatically added
+    assert 'vtkOriginalCellIds' in tet_grid.cell_data

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/filters/test_rectilinear_grid.py
: '>>>>> End Test Output'
git checkout db6ee8dd4a747b8864caae36c5d05883976a3ae5 tests/filters/test_rectilinear_grid.py
