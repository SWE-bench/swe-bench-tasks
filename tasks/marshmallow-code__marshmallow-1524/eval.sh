#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 7015fc4333a2f32cd58c3465296e834acd4496ff
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e '.[dev]'
git checkout 7015fc4333a2f32cd58c3465296e834acd4496ff tests/test_validate.py
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_validate.py b/tests/test_validate.py
--- a/tests/test_validate.py
+++ b/tests/test_validate.py
@@ -41,6 +41,7 @@ def test_url_absolute_valid(valid_url):
     'http:/example.org',
     'foo://example.org',
     '../icons/logo.gif',
+    'https://example.org\n',
     'abc',
     '..',
     '/',
@@ -71,6 +72,7 @@ def test_url_relative_valid(valid_url):
     'suppliers.html',
     '../icons/logo.gif',
     'icons/logo.gif',
+    'http://example.org\n',
     '../.../g',
     '...',
     '\\',
@@ -98,6 +100,7 @@ def test_url_dont_require_tld_valid(valid_url):
 
 @pytest.mark.parametrize('invalid_url', [
     'http//example',
+    'http://example\n',
     'http://.example.org',
     'http:///foo/bar',
     'http:// /foo/bar',
@@ -165,6 +168,8 @@ def test_email_valid(valid_email):
     assert validator(valid_email) == valid_email
 
 @pytest.mark.parametrize('invalid_email', [
+    'niceandsimple\n@example.com',
+    'NiCeAnDsImPlE@eXaMpLe.CoM\n',
     'a"b(c)d,e:f;g<h>i[j\\k]l@example.com',
     'just"not"right@example.com',
     'this is"not\allowed@example.com',

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA tests/test_validate.py
: '>>>>> End Test Output'
git checkout 7015fc4333a2f32cd58c3465296e834acd4496ff tests/test_validate.py
