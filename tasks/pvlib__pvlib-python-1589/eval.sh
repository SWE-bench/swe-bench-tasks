#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff bd86597f62013f576670a452869ea88a47c58c01
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[all]
git checkout bd86597f62013f576670a452869ea88a47c58c01 pvlib/tests/bifacial/test_infinite_sheds.py pvlib/tests/test_shading.py
git apply -v - <<'EOF_114329324912'
diff --git a/pvlib/tests/bifacial/test_infinite_sheds.py b/pvlib/tests/bifacial/test_infinite_sheds.py
--- a/pvlib/tests/bifacial/test_infinite_sheds.py
+++ b/pvlib/tests/bifacial/test_infinite_sheds.py
@@ -106,6 +106,14 @@ def test__ground_angle(test_system):
     assert np.allclose(angles, expected_angles)
 
 
+def test__ground_angle_zero_gcr():
+    surface_tilt = 30.0
+    x = np.array([0.0, 0.5, 1.0])
+    angles = infinite_sheds._ground_angle(x, surface_tilt, 0)
+    expected_angles = np.array([0, 0, 0])
+    assert np.allclose(angles, expected_angles)
+
+
 def test__vf_row_ground(test_system):
     ts, _, _ = test_system
     x = np.array([0., 0.5, 1.0])
diff --git a/pvlib/tests/test_shading.py b/pvlib/tests/test_shading.py
--- a/pvlib/tests/test_shading.py
+++ b/pvlib/tests/test_shading.py
@@ -45,6 +45,13 @@ def test_masking_angle_scalar(surface_tilt, masking_angle):
         assert np.isclose(masking_angle_actual, angle)
 
 
+def test_masking_angle_zero_gcr(surface_tilt):
+    # scalar inputs and outputs, including zero
+    for tilt in surface_tilt:
+        masking_angle_actual = shading.masking_angle(tilt, 0, 0.25)
+        assert np.isclose(masking_angle_actual, 0)
+
+
 def test_masking_angle_passias_series(surface_tilt, average_masking_angle):
     # pandas series inputs and outputs
     masking_angle_actual = shading.masking_angle_passias(surface_tilt, 0.5)

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pvlib/tests/bifacial/test_infinite_sheds.py pvlib/tests/test_shading.py
: '>>>>> End Test Output'
git checkout bd86597f62013f576670a452869ea88a47c58c01 pvlib/tests/bifacial/test_infinite_sheds.py pvlib/tests/test_shading.py
