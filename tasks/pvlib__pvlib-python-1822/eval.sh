#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff d2fbfb247979282ba1fba6794dec451c0b1e8d57
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[all]
git checkout d2fbfb247979282ba1fba6794dec451c0b1e8d57 pvlib/tests/test_singlediode.py
git apply -v - <<'EOF_114329324912'
diff --git a/pvlib/tests/test_singlediode.py b/pvlib/tests/test_singlediode.py
--- a/pvlib/tests/test_singlediode.py
+++ b/pvlib/tests/test_singlediode.py
@@ -557,3 +557,14 @@ def test_bishop88_full_output_kwarg(method, bishop88_arguments):
     assert isinstance(ret_val[1], tuple)  # second is output from optimizer
     # any root finder returns at least 2 elements with full_output=True
     assert len(ret_val[1]) >= 2
+
+
+@pytest.mark.parametrize('method', ['newton', 'brentq'])
+def test_bishop88_pdSeries_len_one(method, bishop88_arguments):
+    for k, v in bishop88_arguments.items():
+        bishop88_arguments[k] = pd.Series([v])
+
+    # should not raise error
+    bishop88_i_from_v(pd.Series([0]), **bishop88_arguments, method=method)
+    bishop88_v_from_i(pd.Series([0]), **bishop88_arguments, method=method)
+    bishop88_mpp(**bishop88_arguments, method=method)

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pvlib/tests/test_singlediode.py
: '>>>>> End Test Output'
git checkout d2fbfb247979282ba1fba6794dec451c0b1e8d57 pvlib/tests/test_singlediode.py
