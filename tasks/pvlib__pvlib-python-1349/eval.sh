#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff aba071f707f9025882e57f3e55cc9e3e90e869b2
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[all]
git checkout aba071f707f9025882e57f3e55cc9e3e90e869b2 pvlib/tests/test_spectrum.py
git apply -v - <<'EOF_114329324912'
diff --git a/pvlib/tests/test_spectrum.py b/pvlib/tests/test_spectrum.py
--- a/pvlib/tests/test_spectrum.py
+++ b/pvlib/tests/test_spectrum.py
@@ -92,3 +92,17 @@ def test_dayofyear_missing(spectrl2_data):
     kwargs.pop('dayofyear')
     with pytest.raises(ValueError, match='dayofyear must be specified'):
         _ = spectrum.spectrl2(**kwargs)
+
+
+def test_aoi_gt_90(spectrl2_data):
+    # test that returned irradiance values are non-negative when aoi > 90
+    # see GH #1348
+    kwargs, _ = spectrl2_data
+    kwargs['apparent_zenith'] = 70
+    kwargs['aoi'] = 130
+    kwargs['surface_tilt'] = 60
+
+    spectra = spectrum.spectrl2(**kwargs)
+    for key in ['poa_direct', 'poa_global']:
+        message = f'{key} contains negative values for aoi>90'
+        assert np.all(spectra[key] >= 0), message

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pvlib/tests/test_spectrum.py
: '>>>>> End Test Output'
git checkout aba071f707f9025882e57f3e55cc9e3e90e869b2 pvlib/tests/test_spectrum.py
