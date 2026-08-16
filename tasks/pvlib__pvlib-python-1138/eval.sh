#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 56971c614e7faea3c24013445f1bf6ffe9943305
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[all]
git checkout 56971c614e7faea3c24013445f1bf6ffe9943305 pvlib/tests/test_modelchain.py
git apply -v - <<'EOF_114329324912'
diff --git a/pvlib/tests/test_modelchain.py b/pvlib/tests/test_modelchain.py
--- a/pvlib/tests/test_modelchain.py
+++ b/pvlib/tests/test_modelchain.py
@@ -1180,6 +1180,25 @@ def test_dc_model_user_func(pvwatts_dc_pvwatts_ac_system, location, weather,
     assert not mc.results.ac.empty
 
 
+def test_pvwatts_dc_multiple_strings(pvwatts_dc_pvwatts_ac_system, location,
+                                     weather, mocker):
+    system = pvwatts_dc_pvwatts_ac_system
+    m = mocker.spy(system, 'scale_voltage_current_power')
+    mc1 = ModelChain(system, location,
+                     aoi_model='no_loss', spectral_model='no_loss')
+    mc1.run_model(weather)
+    assert m.call_count == 1
+    system.arrays[0].modules_per_string = 2
+    mc2 = ModelChain(system, location,
+                     aoi_model='no_loss', spectral_model='no_loss')
+    mc2.run_model(weather)
+    assert isinstance(mc2.results.ac, (pd.Series, pd.DataFrame))
+    assert not mc2.results.ac.empty
+    expected = pd.Series(data=[2., np.nan], index=mc2.results.dc.index,
+                         name='p_mp')
+    assert_series_equal(mc2.results.dc / mc1.results.dc, expected)
+
+
 def acdc(mc):
     mc.results.ac = mc.results.dc
 

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pvlib/tests/test_modelchain.py
: '>>>>> End Test Output'
git checkout 56971c614e7faea3c24013445f1bf6ffe9943305 pvlib/tests/test_modelchain.py
