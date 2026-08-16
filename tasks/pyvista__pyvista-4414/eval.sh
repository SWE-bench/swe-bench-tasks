#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 438dd0d6ea2ebee73ecccdba878837af8fd83d7d
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 438dd0d6ea2ebee73ecccdba878837af8fd83d7d tests/test_polydata.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_polydata.py b/tests/test_polydata.py
--- a/tests/test_polydata.py
+++ b/tests/test_polydata.py
@@ -340,6 +340,16 @@ def test_merge(sphere, sphere_shifted, hexbeam):
     merged = mesh.merge(sphere_shifted, inplace=True)
     assert merged is mesh
 
+    # test merge with lines
+    arc_1 = pyvista.CircularArc([0, 0, 0], [10, 10, 0], [10, 0, 0], negative=False, resolution=3)
+    arc_2 = pyvista.CircularArc([10, 10, 0], [20, 0, 0], [10, 0, 0], negative=False, resolution=3)
+    merged = arc_1 + arc_2
+    assert merged.n_lines == 2
+
+    # test merge with lines as iterable
+    merged = arc_1.merge((arc_2, arc_2))
+    assert merged.n_lines == 3
+
     # test main_has_priority
     mesh = sphere.copy()
     data_main = np.arange(mesh.n_points, dtype=float)

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/test_polydata.py
: '>>>>> End Test Output'
git checkout 438dd0d6ea2ebee73ecccdba878837af8fd83d7d tests/test_polydata.py
