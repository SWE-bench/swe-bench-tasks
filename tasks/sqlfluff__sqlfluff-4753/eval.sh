#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 24178a589c279220c6605324c446122d15ebc3fb
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 24178a589c279220c6605324c446122d15ebc3fb test/api/simple_test.py
git apply -v - <<'EOF_114329324912'
diff --git a/test/api/simple_test.py b/test/api/simple_test.py
--- a/test/api/simple_test.py
+++ b/test/api/simple_test.py
@@ -95,7 +95,7 @@
         "line_no": 1,
         "line_pos": 41,
         "description": "Files must end with a single trailing newline.",
-        "name": "layout.end-of-file",
+        "name": "layout.end_of_file",
     },
 ]
 

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA test/api/simple_test.py
: '>>>>> End Test Output'
git checkout 24178a589c279220c6605324c446122d15ebc3fb test/api/simple_test.py
