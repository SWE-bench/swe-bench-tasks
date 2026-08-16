#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 47654a073e0eb2b48b2ccdadb5cade9be0484b73
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[all]
git checkout 47654a073e0eb2b48b2ccdadb5cade9be0484b73 pvlib/tests/test_modelchain.py
git apply -v - <<'EOF_114329324912'
diff --git a/pvlib/tests/test_modelchain.py b/pvlib/tests/test_modelchain.py
--- a/pvlib/tests/test_modelchain.py
+++ b/pvlib/tests/test_modelchain.py
@@ -726,6 +726,29 @@ def test_run_model_tracker(sapm_dc_snl_ac_system, location, weather, mocker):
                                             'surface_tilt']).all()
     assert mc.results.ac[0] > 0
     assert np.isnan(mc.results.ac[1])
+    assert isinstance(mc.results.dc, pd.DataFrame)
+
+
+def test_run_model_tracker_list(
+        sapm_dc_snl_ac_system, location, weather, mocker):
+    system = SingleAxisTracker(
+        module_parameters=sapm_dc_snl_ac_system.module_parameters,
+        temperature_model_parameters=(
+            sapm_dc_snl_ac_system.temperature_model_parameters
+        ),
+        inverter_parameters=sapm_dc_snl_ac_system.inverter_parameters)
+    mocker.spy(system, 'singleaxis')
+    mc = ModelChain(system, location)
+    mc.run_model([weather])
+    assert system.singleaxis.call_count == 1
+    assert (mc.results.tracking.columns == ['tracker_theta',
+                                            'aoi',
+                                            'surface_azimuth',
+                                            'surface_tilt']).all()
+    assert mc.results.ac[0] > 0
+    assert np.isnan(mc.results.ac[1])
+    assert isinstance(mc.results.dc, tuple)
+    assert len(mc.results.dc) == 1
 
 
 def test__assign_total_irrad(sapm_dc_snl_ac_system, location, weather,

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pvlib/tests/test_modelchain.py
: '>>>>> End Test Output'
git checkout 47654a073e0eb2b48b2ccdadb5cade9be0484b73 pvlib/tests/test_modelchain.py
