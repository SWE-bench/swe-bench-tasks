from_json does not correctly convert BulkDataURI's in SQ data elements
**Describe the bug**
When a DICOM object contains large data elements in SQ elements and is converted to JSON, those elements are correctly turned into BulkDataURI's. However, when the JSON is converted back to DICOM using from_json, the BulkDataURI's in SQ data elements are not converted back and warnings are thrown.

**Expected behavior**
The BulkDataURI's in SQ data elements get converted back correctly.

**Steps To Reproduce**
Take the `waveform_ecg.dcm` in the test data, convert it to JSON, and then convert the JSON to DICOM

**Your environment**
module       | version
------       | -------
platform     | macOS-10.15.7-x86_64-i386-64bit
Python       | 3.8.2 (v3.8.2:7b3ab5921f, Feb 24 2020, 17:52:18)  [Clang 6.0 (clang-600.0.57)]
pydicom      | 2.1.0
gdcm         | _module not found_
jpeg_ls      | _module not found_
numpy        | _module not found_
PIL          | _module not found_

The problem is in `jsonrep.py` at line 227. I plan on submitting a pull-request today for this.
