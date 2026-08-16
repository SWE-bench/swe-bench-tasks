#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 0f800862380f60efb1841e5e0b116e945a3079a9
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 0f800862380f60efb1841e5e0b116e945a3079a9 tests/test_composite.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_composite.py b/tests/test_composite.py
--- a/tests/test_composite.py
+++ b/tests/test_composite.py
@@ -135,7 +135,7 @@ def test_multi_block_set_get_ers():
     for i in [0, 2, 3, 4, 5]:
         assert multi[i] is None
     # Check the bounds
-    assert multi.bounds == list(data.bounds)
+    assert multi.bounds == data.bounds
     multi[5] = ex.load_uniform()
     multi.set_block_name(5, 'uni')
     multi.set_block_name(5, None)  # Make sure it doesn't get overwritten

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/test_composite.py
: '>>>>> End Test Output'
git checkout 0f800862380f60efb1841e5e0b116e945a3079a9 tests/test_composite.py
