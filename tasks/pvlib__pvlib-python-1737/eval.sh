#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 5119b4281fa9de8a4dc97002b5c10a6d73c25a4f
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[all]
git checkout 5119b4281fa9de8a4dc97002b5c10a6d73c25a4f pvlib/tests/iotools/test_tmy.py
git apply -v - <<'EOF_114329324912'
diff --git a/pvlib/tests/iotools/test_tmy.py b/pvlib/tests/iotools/test_tmy.py
--- a/pvlib/tests/iotools/test_tmy.py
+++ b/pvlib/tests/iotools/test_tmy.py
@@ -121,7 +121,8 @@ def test_solaranywhere_tmy3(solaranywhere_index):
     # The SolarAnywhere TMY3 format specifies midnight as 00:00 whereas the
     # NREL TMY3 format utilizes 24:00. The SolarAnywhere file is therefore
     # included to test files with  00:00 timestamps are parsed correctly
-    data, meta = tmy.read_tmy3(TMY3_SOLARANYWHERE, map_variables=False)
+    data, meta = tmy.read_tmy3(TMY3_SOLARANYWHERE, encoding='iso-8859-1',
+                               map_variables=False)
     pd.testing.assert_index_equal(data.index, solaranywhere_index)
     assert meta['USAF'] == 0
     assert meta['Name'] == 'Burlington  United States'

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pvlib/tests/iotools/test_tmy.py
: '>>>>> End Test Output'
git checkout 5119b4281fa9de8a4dc97002b5c10a6d73c25a4f pvlib/tests/iotools/test_tmy.py
