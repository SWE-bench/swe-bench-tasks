#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 0415365031ca8d0b2867f2a2877e0ad9d7098ffc
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[all]
git checkout 0415365031ca8d0b2867f2a2877e0ad9d7098ffc pvlib/tests/test_irradiance.py
git apply -v - <<'EOF_114329324912'
diff --git a/pvlib/tests/test_irradiance.py b/pvlib/tests/test_irradiance.py
--- a/pvlib/tests/test_irradiance.py
+++ b/pvlib/tests/test_irradiance.py
@@ -792,6 +792,27 @@ def test_aoi_and_aoi_projection(surface_tilt, surface_azimuth, solar_zenith,
     assert_allclose(aoi_projection, aoi_proj_expected, atol=1e-6)
 
 
+def test_aoi_projection_precision():
+    # GH 1185 -- test that aoi_projection does not exceed 1.0, and when
+    # given identical inputs, the returned projection is very close to 1.0
+
+    # scalars
+    zenith = 89.26778228223463
+    azimuth = 60.932028605997004
+    projection = irradiance.aoi_projection(zenith, azimuth, zenith, azimuth)
+    assert projection <= 1
+    assert np.isclose(projection, 1)
+
+    # arrays
+    zeniths = np.array([zenith])
+    azimuths = np.array([azimuth])
+    projections = irradiance.aoi_projection(zeniths, azimuths,
+                                            zeniths, azimuths)
+    assert all(projections <= 1)
+    assert all(np.isclose(projections, 1))
+    assert projections.dtype == np.dtype('float64')
+
+
 @pytest.fixture
 def airmass_kt():
     # disc algorithm stopped at am=12. test am > 12 for out of range behavior

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pvlib/tests/test_irradiance.py
: '>>>>> End Test Output'
git checkout 0415365031ca8d0b2867f2a2877e0ad9d7098ffc pvlib/tests/test_irradiance.py
