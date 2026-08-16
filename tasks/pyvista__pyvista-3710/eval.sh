#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 846f1834f7428acff9395ef4b8a3bd39b42c99e6
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 846f1834f7428acff9395ef4b8a3bd39b42c99e6 tests/test_geometric_objects.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_geometric_objects.py b/tests/test_geometric_objects.py
--- a/tests/test_geometric_objects.py
+++ b/tests/test_geometric_objects.py
@@ -275,6 +275,11 @@ def test_circle():
     assert mesh.n_cells
     diameter = np.max(mesh.points[:, 0]) - np.min(mesh.points[:, 0])
     assert np.isclose(diameter, radius * 2.0, rtol=1e-3)
+    line_lengths = np.linalg.norm(
+        np.roll(mesh.points, shift=1, axis=0) - mesh.points,
+        axis=1,
+    )
+    assert np.allclose(line_lengths[0], line_lengths)
 
 
 def test_ellipse():

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/test_geometric_objects.py
: '>>>>> End Test Output'
git checkout 846f1834f7428acff9395ef4b8a3bd39b42c99e6 tests/test_geometric_objects.py
