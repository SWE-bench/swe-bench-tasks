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
@@ -281,13 +281,35 @@ def test_sky_diffuse_zenith_close_to_90(model):
     assert sky_diffuse < 100
 
 
-def test_get_sky_diffuse_invalid():
+def test_get_sky_diffuse_model_invalid():
     with pytest.raises(ValueError):
         irradiance.get_sky_diffuse(
             30, 180, 0, 180, 1000, 1100, 100, dni_extra=1360, airmass=1,
             model='invalid')
 
 
+def test_get_sky_diffuse_missing_dni_extra():
+    msg = 'dni_extra is required'
+    with pytest.raises(ValueError, match=msg):
+        irradiance.get_sky_diffuse(
+            30, 180, 0, 180, 1000, 1100, 100, airmass=1,
+            model='haydavies')
+
+
+def test_get_sky_diffuse_missing_airmass(irrad_data, ephem_data, dni_et):
+    # test assumes location is Tucson, AZ
+    # calculated airmass should be the equivalent to fixture airmass
+    dni = irrad_data['dni'].copy()
+    dni.iloc[2] = np.nan
+    out = irradiance.get_sky_diffuse(
+        40, 180, ephem_data['apparent_zenith'], ephem_data['azimuth'], dni,
+        irrad_data['ghi'], irrad_data['dhi'], dni_et,  model='perez')
+    expected = pd.Series(np.array(
+        [0., 31.46046871, np.nan, 45.45539877]),
+        index=irrad_data.index)
+    assert_series_equal(out, expected, check_less_precise=2)
+
+
 def test_campbell_norman():
     expected = pd.DataFrame(np.array(
         [[863.859736967, 653.123094076, 220.65905025]]),
@@ -299,7 +321,8 @@ def test_campbell_norman():
     assert_frame_equal(out, expected)
 
 
-def test_get_total_irradiance(irrad_data, ephem_data, dni_et, relative_airmass):
+def test_get_total_irradiance(irrad_data, ephem_data, dni_et,
+                              relative_airmass):
     models = ['isotropic', 'klucher',
               'haydavies', 'reindl', 'king', 'perez']
 
@@ -337,6 +360,30 @@ def test_get_total_irradiance_scalars(model):
     assert np.isnan(np.array(list(total.values()))).sum() == 0
 
 
+def test_get_total_irradiance_missing_dni_extra():
+    msg = 'dni_extra is required'
+    with pytest.raises(ValueError, match=msg):
+        irradiance.get_total_irradiance(
+            32, 180,
+            10, 180,
+            dni=1000, ghi=1100,
+            dhi=100,
+            model='haydavies')
+
+
+def test_get_total_irradiance_missing_airmass():
+    total = irradiance.get_total_irradiance(
+        32, 180,
+        10, 180,
+        dni=1000, ghi=1100,
+        dhi=100,
+        dni_extra=1400,
+        model='perez')
+    assert list(total.keys()) == ['poa_global', 'poa_direct',
+                                  'poa_diffuse', 'poa_sky_diffuse',
+                                  'poa_ground_diffuse']
+
+
 def test_poa_components(irrad_data, ephem_data, dni_et, relative_airmass):
     aoi = irradiance.aoi(40, 180, ephem_data['apparent_zenith'],
                          ephem_data['azimuth'])

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pvlib/tests/test_irradiance.py
: '>>>>> End Test Output'
git checkout 0415365031ca8d0b2867f2a2877e0ad9d7098ffc pvlib/tests/test_irradiance.py
