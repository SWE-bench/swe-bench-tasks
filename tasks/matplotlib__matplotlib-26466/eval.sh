#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 3dd06a46750d174f821df5377996f493f1af4ebb
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git checkout 3dd06a46750d174f821df5377996f493f1af4ebb lib/matplotlib/tests/test_text.py
git apply -v - <<'EOF_114329324912'
diff --git a/lib/matplotlib/tests/test_text.py b/lib/matplotlib/tests/test_text.py
--- a/lib/matplotlib/tests/test_text.py
+++ b/lib/matplotlib/tests/test_text.py
@@ -988,3 +988,13 @@
 
     mpl.rcParams['text.antialiased'] = False
     fig_ref.text(0.5, 0.5, r"OutsideMath $I\'m \sqrt{2}$")
+
+
+@check_figures_equal(extensions=["png"])
+def test_annotate_and_offsetfrom_copy_input(fig_test, fig_ref):
+    xy = np.array([.25, .25])
+    for fig, annotation_xy in ((fig_test, xy), (fig_ref, (.25, .25))):
+        ax = fig.add_subplot(xlim=(0, 1), ylim=(0, 1))
+        ax.annotate("foo", xy=annotation_xy, xytext=(.75, .75),
+                    arrowprops=dict(arrowstyle="->"))
+    xy[:] = .5

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA lib/matplotlib/tests/test_text.py
: '>>>>> End Test Output'
git checkout 3dd06a46750d174f821df5377996f493f1af4ebb lib/matplotlib/tests/test_text.py
