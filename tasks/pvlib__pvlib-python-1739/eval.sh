#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 909f86dc67eddc88154c9e7bff73fd9d6bfe2e4d
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[all]
git checkout 909f86dc67eddc88154c9e7bff73fd9d6bfe2e4d pvlib/tests/iotools/test_pvgis.py
git apply -v - <<'EOF_114329324912'
diff --git a/pvlib/tests/iotools/test_pvgis.py b/pvlib/tests/iotools/test_pvgis.py
--- a/pvlib/tests/iotools/test_pvgis.py
+++ b/pvlib/tests/iotools/test_pvgis.py
@@ -206,14 +206,14 @@ def test_read_pvgis_hourly_bad_extension():
 
 
 args_radiation_csv = {
-    'surface_tilt': 30, 'surface_azimuth': 0, 'outputformat': 'csv',
+    'surface_tilt': 30, 'surface_azimuth': 180, 'outputformat': 'csv',
     'usehorizon': False, 'userhorizon': None, 'raddatabase': 'PVGIS-SARAH',
     'start': 2016, 'end': 2016, 'pvcalculation': False, 'components': True}
 
 url_hourly_radiation_csv = 'https://re.jrc.ec.europa.eu/api/seriescalc?lat=45&lon=8&outputformat=csv&angle=30&aspect=0&usehorizon=0&pvtechchoice=crystSi&mountingplace=free&trackingtype=0&components=1&raddatabase=PVGIS-SARAH&startyear=2016&endyear=2016'  # noqa: E501
 
 args_pv_json = {
-    'surface_tilt': 30, 'surface_azimuth': 0, 'outputformat': 'json',
+    'surface_tilt': 30, 'surface_azimuth': 180, 'outputformat': 'json',
     'usehorizon': True, 'userhorizon': None, 'raddatabase': 'PVGIS-SARAH2',
     'start': pd.Timestamp(2013, 1, 1), 'end': pd.Timestamp(2014, 5, 1),
     'pvcalculation': True, 'peakpower': 10, 'pvtechchoice': 'CIS', 'loss': 5,

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pvlib/tests/iotools/test_pvgis.py
: '>>>>> End Test Output'
git checkout 909f86dc67eddc88154c9e7bff73fd9d6bfe2e4d pvlib/tests/iotools/test_pvgis.py
