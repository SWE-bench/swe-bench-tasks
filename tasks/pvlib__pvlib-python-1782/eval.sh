#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 0bc5a53dedd8aa9e553c732a31003ce020bc2f54
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[all]
git checkout 0bc5a53dedd8aa9e553c732a31003ce020bc2f54 pvlib/tests/test_singlediode.py
git apply -v - <<'EOF_114329324912'
diff --git a/pvlib/tests/test_singlediode.py b/pvlib/tests/test_singlediode.py
--- a/pvlib/tests/test_singlediode.py
+++ b/pvlib/tests/test_singlediode.py
@@ -168,6 +168,19 @@ def test_singlediode_precision(method, precise_iv_curves):
     assert np.allclose(pc['i_xx'], outs['i_xx'], atol=1e-6, rtol=0)
 
 
+def test_singlediode_lambert_negative_voc():
+
+    # Those values result in a negative v_oc out of `_lambertw_v_from_i`
+    x = np.array([0., 1.480501e-11, 0.178, 8000., 1.797559])
+    outs = pvsystem.singlediode(*x, method='lambertw')
+    assert outs['v_oc'] == 0
+
+    # Testing for an array
+    x  = np.array([x, x]).T
+    outs = pvsystem.singlediode(*x, method='lambertw')
+    assert np.array_equal(outs['v_oc'], [0, 0])
+
+
 @pytest.mark.parametrize('method', ['lambertw'])
 def test_ivcurve_pnts_precision(method, precise_iv_curves):
     """

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pvlib/tests/test_singlediode.py
: '>>>>> End Test Output'
git checkout 0bc5a53dedd8aa9e553c732a31003ce020bc2f54 pvlib/tests/test_singlediode.py
