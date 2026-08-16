#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 699c9f0a8e190d463dd828822106250523d38154
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 699c9f0a8e190d463dd828822106250523d38154 pydicom/tests/test_handler_util.py
git apply -v - <<'EOF_114329324912'
diff --git a/pydicom/tests/test_handler_util.py b/pydicom/tests/test_handler_util.py
--- a/pydicom/tests/test_handler_util.py
+++ b/pydicom/tests/test_handler_util.py
@@ -1252,6 +1252,11 @@ def test_linear(self):
         out = _expand_segmented_lut(data, 'H')
         assert [-400, -320, -240, -160, -80, 0] == out
 
+        # Positive slope, floating point steps
+        data = (0, 1, 163, 1, 48, 255)
+        out = _expand_segmented_lut(data, 'H')
+        assert (1 + 48) == len(out)
+
         # No slope
         data = (0, 2, 0, 28672, 1, 5, 28672)
         out = _expand_segmented_lut(data, 'H')

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pydicom/tests/test_handler_util.py
: '>>>>> End Test Output'
git checkout 699c9f0a8e190d463dd828822106250523d38154 pydicom/tests/test_handler_util.py
