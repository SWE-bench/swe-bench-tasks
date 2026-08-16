#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 275e6718caf7486cb5b7dcf29acd59499ad51f7f
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[all]
git checkout 275e6718caf7486cb5b7dcf29acd59499ad51f7f pvlib/tests/iotools/test_sodapro.py
git apply -v - <<'EOF_114329324912'
diff --git a/pvlib/tests/iotools/test_sodapro.py b/pvlib/tests/iotools/test_sodapro.py
--- a/pvlib/tests/iotools/test_sodapro.py
+++ b/pvlib/tests/iotools/test_sodapro.py
@@ -209,7 +209,7 @@ def test_get_cams(requests_mock, testfile, index, columns, values, dtypes,
         mock_response = test_file.read()
     # Specify the full URI of a specific example, this ensures that all of the
     # inputs are passing on correctly
-    url_test_cams = f'https://www.soda-is.com/service/wps?DataInputs=latitude=55.7906;longitude=12.5251;altitude=80;date_begin=2020-01-01;date_end=2020-05-04;time_ref=UT;summarization=P01M;username=pvlib-admin%2540googlegroups.com;verbose=false&Service=WPS&Request=Execute&Identifier=get_{identifier}&version=1.0.0&RawDataOutput=irradiation'  # noqa: E501
+    url_test_cams = f'https://api.soda-solardata.com/service/wps?DataInputs=latitude=55.7906;longitude=12.5251;altitude=80;date_begin=2020-01-01;date_end=2020-05-04;time_ref=UT;summarization=P01M;username=pvlib-admin%2540googlegroups.com;verbose=false&Service=WPS&Request=Execute&Identifier=get_{identifier}&version=1.0.0&RawDataOutput=irradiation'  # noqa: E501
 
     requests_mock.get(url_test_cams, text=mock_response,
                       headers={'Content-Type': 'application/csv'})

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pvlib/tests/iotools/test_sodapro.py
: '>>>>> End Test Output'
git checkout 275e6718caf7486cb5b7dcf29acd59499ad51f7f pvlib/tests/iotools/test_sodapro.py
