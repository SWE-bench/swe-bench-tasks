#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 50dcc7fe412d9e27fe06670b8057e3d8e9ce5b19
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[all]
git checkout 50dcc7fe412d9e27fe06670b8057e3d8e9ce5b19 pvlib/tests/test_pvsystem.py
git apply -v - <<'EOF_114329324912'
diff --git a/pvlib/tests/test_pvsystem.py b/pvlib/tests/test_pvsystem.py
--- a/pvlib/tests/test_pvsystem.py
+++ b/pvlib/tests/test_pvsystem.py
@@ -2084,6 +2084,12 @@ def test_PVSystem_num_arrays():
     assert system_two.num_arrays == 2
 
 
+def test_PVSystem_at_least_one_array():
+    with pytest.raises(ValueError,
+                       match="PVSystem must have at least one Array"):
+        pvsystem.PVSystem(arrays=[])
+
+
 def test_combine_loss_factors():
     test_index = pd.date_range(start='1990/01/01T12:00', periods=365, freq='D')
     loss_1 = pd.Series(.10, index=test_index)

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pvlib/tests/test_pvsystem.py
: '>>>>> End Test Output'
git checkout 50dcc7fe412d9e27fe06670b8057e3d8e9ce5b19 pvlib/tests/test_pvsystem.py
