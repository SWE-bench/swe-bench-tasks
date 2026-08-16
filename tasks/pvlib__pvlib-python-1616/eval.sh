#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 25af86599845f23b0ce57dc1cbe743b3a1e68d1a
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[all]
git checkout 25af86599845f23b0ce57dc1cbe743b3a1e68d1a pvlib/tests/test_iam.py
git apply -v - <<'EOF_114329324912'
diff --git a/pvlib/tests/test_iam.py b/pvlib/tests/test_iam.py
--- a/pvlib/tests/test_iam.py
+++ b/pvlib/tests/test_iam.py
@@ -42,7 +42,7 @@ def test_physical():
     expected = np.array([0, 0.8893998, 0.98797788, 0.99926198, 1, 0.99926198,
                          0.98797788, 0.8893998, 0, np.nan])
     iam = _iam.physical(aoi, 1.526, 0.002, 4)
-    assert_allclose(iam, expected, equal_nan=True)
+    assert_allclose(iam, expected, atol=1e-7, equal_nan=True)
 
     # GitHub issue 397
     aoi = pd.Series(aoi)
@@ -51,6 +51,22 @@ def test_physical():
     assert_series_equal(iam, expected)
 
 
+def test_physical_ar():
+    aoi = np.array([0, 22.5, 45, 67.5, 90, 100, np.nan])
+    expected = np.array([1, 0.99944171, 0.9917463, 0.91506158, 0, 0, np.nan])
+    iam = _iam.physical(aoi, n_ar=1.29)
+    assert_allclose(iam, expected, atol=1e-7, equal_nan=True)
+
+
+def test_physical_noar():
+    aoi = np.array([0, 22.5, 45, 67.5, 90, 100, np.nan])
+    expected = _iam.physical(aoi)
+    iam0 = _iam.physical(aoi, n_ar=1)
+    iam1 = _iam.physical(aoi, n_ar=1.526)
+    assert_allclose(iam0, expected, equal_nan=True)
+    assert_allclose(iam1, expected, equal_nan=True)
+
+
 def test_physical_scalar():
     aoi = -45.
     iam = _iam.physical(aoi, 1.526, 0.002, 4)

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pvlib/tests/test_iam.py
: '>>>>> End Test Output'
git checkout 25af86599845f23b0ce57dc1cbe743b3a1e68d1a pvlib/tests/test_iam.py
