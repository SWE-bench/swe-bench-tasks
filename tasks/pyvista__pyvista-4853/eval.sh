#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 4a44e4c63c6b8d6a3f1db0aa193f4ccb631ed698
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 4a44e4c63c6b8d6a3f1db0aa193f4ccb631ed698 tests/core/test_parametric_geometry.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/core/test_parametric_geometry.py b/tests/core/test_parametric_geometry.py
--- a/tests/core/test_parametric_geometry.py
+++ b/tests/core/test_parametric_geometry.py
@@ -148,3 +148,15 @@ def test_ParametricSuperToroid():
 def test_ParametricTorus():
     geom = pv.ParametricTorus()
     assert geom.n_points
+
+
+def test_direction():
+    geom1 = pv.ParametricEllipsoid(300, 100, 10, direction=[1, 0, 0])
+    geom2 = pv.ParametricEllipsoid(300, 100, 10, direction=[0, 1, 0])
+    assert geom1.n_points
+    assert geom2.n_points
+    points1 = geom1.points
+    points2 = geom2.points
+    assert np.allclose(points1[:, 0], points2[:, 1])
+    assert np.allclose(points1[:, 1], -points2[:, 0])
+    assert np.allclose(points1[:, 2], points2[:, 2])

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/core/test_parametric_geometry.py
: '>>>>> End Test Output'
git checkout 4a44e4c63c6b8d6a3f1db0aa193f4ccb631ed698 tests/core/test_parametric_geometry.py
