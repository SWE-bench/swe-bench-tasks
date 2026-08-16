#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 7fc595a13bcd42e3269c0806f5505ac907af9730
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[all]
git checkout 7fc595a13bcd42e3269c0806f5505ac907af9730 pvlib/tests/ivtools/test_utils.py
git apply -v - <<'EOF_114329324912'
diff --git a/pvlib/tests/ivtools/test_utility.py b/pvlib/tests/ivtools/test_utils.py
similarity index 96%
rename from pvlib/tests/ivtools/test_utility.py
rename to pvlib/tests/ivtools/test_utils.py
--- a/pvlib/tests/ivtools/test_utility.py
+++ b/pvlib/tests/ivtools/test_utils.py
@@ -1,8 +1,8 @@
 import numpy as np
 import pandas as pd
 import pytest
-from pvlib.ivtools.utility import _numdiff, rectify_iv_curve
-from pvlib.ivtools.utility import _schumaker_qspline
+from pvlib.ivtools.utils import _numdiff, rectify_iv_curve
+from pvlib.ivtools.utils import _schumaker_qspline
 
 from conftest import DATA_DIR
 

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pvlib/tests/ivtools/test_utils.py
: '>>>>> End Test Output'
git checkout 7fc595a13bcd42e3269c0806f5505ac907af9730 pvlib/tests/ivtools/test_utils.py
