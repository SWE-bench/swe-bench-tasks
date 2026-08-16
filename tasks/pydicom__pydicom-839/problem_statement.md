Ambiguous VR element could be read in <=1.1.0 but is broken in >=1.2.0
<!-- Instructions For Filing a Bug: https://github.com/pydicom/pydicom/blob/master/CONTRIBUTING.md#filing-bugs -->

#### Description
Attribute Error thrown when printing (0x0028, 0x0120) PixelPaddingValue

#### Steps/Code to Reproduce
Using pydicom 1.2.2 and above (including master branch as of issue creation date):
```
from pydicom import dcmread

ds = dcmread('rtss.dcm')
ds

Exception in thread Thread-1:
Traceback (most recent call last):
  File "/Users/apanchal/Projects/venvs/dicom/lib/python3.7/site-packages/pydicom/filewriter.py", line 157, in correct_ambiguous_vr_element
    _correct_ambiguous_vr_element(elem, ds, is_little_endian)
  File "/Users/apanchal/Projects/venvs/dicom/lib/python3.7/site-packages/pydicom/filewriter.py", line 75, in _correct_ambiguous_vr_element
    if ds.PixelRepresentation == 0:
  File "/Users/apanchal/Projects/venvs/dicom/lib/python3.7/site-packages/pydicom/dataset.py", line 711, in __getattr__
    return super(Dataset, self).__getattribute__(name)
AttributeError: 'FileDataset' object has no attribute 'PixelRepresentation'

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/usr/local/Cellar/python/3.7.0/Frameworks/Python.framework/Versions/3.7/lib/python3.7/threading.py", line 917, in _bootstrap_inner
    self.run()
  File "/usr/local/Cellar/python/3.7.0/Frameworks/Python.framework/Versions/3.7/lib/python3.7/threading.py", line 865, in run
    self._target(*self._args, **self._kwargs)
  File "/Users/apanchal/Projects/test.py", line 107, in processing_thread
    dp.ds, name, patientid, patientdob)
  File "/Users/apanchal/Projects/test.py", line 144, in UpdateElements
    for item in data:
  File "/Users/apanchal/Projects/venvs/dicom/lib/python3.7/site-packages/pydicom/dataset.py", line 1045, in __iter__
    yield self[tag]
  File "/Users/apanchal/Projects/venvs/dicom/lib/python3.7/site-packages/pydicom/dataset.py", line 805, in __getitem__
    self[tag], self, data_elem[6])
  File "/Users/apanchal/Projects/venvs/dicom/lib/python3.7/site-packages/pydicom/filewriter.py", line 161, in correct_ambiguous_vr_element
    raise AttributeError(reason)
AttributeError: Failed to resolve ambiguous VR for tag (0028, 0120): 'FileDataset' object has no attribute 'PixelRepresentation'
```

Anonymized RTSTRUCT file is attached: [RTSTRUCT.zip](https://github.com/pydicom/pydicom/files/3124625/RTSTRUCT.zip)

#### Expected Results
The dataset is printed. This worked in pydicom 1.1.0 and below.

Since `PixelRepresentation` is not defined in the dataset, this attribute cannot be printed anymore.

What's strange is that according to the standard PixelPaddingValue (0028, 0120) is 1C for RTSTRUCT, but in this file it has no other tags referencing PixelData. So it probably should not have been included by the vendor.

I am wondering if there should be another path like in #809 that can handle the missing PixelRepresentation attribute.

#### Actual Results
```AttributeError: Failed to resolve ambiguous VR for tag (0028, 0120): 'FileDataset' object has no attribute 'PixelRepresentation'```

#### Versions
```
Darwin-17.7.0-x86_64-i386-64bit
Python 3.7.0 (default, Jul 23 2018, 20:22:55) 
[Clang 9.1.0 (clang-902.0.39.2)]
pydicom 1.2.2
```
