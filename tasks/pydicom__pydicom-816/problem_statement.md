LookupError: unknown encoding: Not Supplied
#### Description
Output from `ds = pydicom.read_file(dcmFile)` (an RTSTRUCT dicom file, SOP UID 1.2.840.10008.5.1.4.1.1.481.3) results in some tags throwing a LookupError: "LookupError: unknown encoding: Not Supplied"
Specific tags which cannot be decoded are as follows:
['DeviceSerialNumber',
 'Manufacturer',
 'ManufacturerModelName',
 'PatientID',
 'PatientName',
 'RTROIObservationsSequence',
 'ReferringPhysicianName',
 'SeriesDescription',
 'SoftwareVersions',
 'StructureSetLabel',
 'StructureSetName',
 'StructureSetROISequence',
 'StudyDescription',
 'StudyID']

I suspect that it's due to the fact that `ds.SpecificCharacterSet = 'Not Supplied'`, but when I try to set `ds.SpecificCharacterSet` to something reasonable (ie ISO_IR_100 or 'iso8859'), it doesn't seem to make any difference.

Reading the same file, with NO modifications, in gdcm does not result in any errors and all fields are readable.

#### Steps/Code to Reproduce
```py
import pydicom 
ds = pydicom.read_file(dcmFile)
print(ds.PatientName)
```

#### Expected Results
No error is thrown and the name of the patient is printed.

#### Actual Results
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "C:\Users\Amanda\AppData\Local\Continuum\anaconda3\envs\itk\lib\site-packages\pydicom\valuerep.py", line 706, in __str__
    return '='.join(self.components).__str__()
  File "C:\Users\Amanda\AppData\Local\Continuum\anaconda3\envs\itk\lib\site-packages\pydicom\valuerep.py", line 641, in components
    self._components = _decode_personname(groups, self.encodings)
  File "C:\Users\Amanda\AppData\Local\Continuum\anaconda3\envs\itk\lib\site-packages\pydicom\valuerep.py", line 564, in _decode_personname
    for comp in components]
  File "C:\Users\Amanda\AppData\Local\Continuum\anaconda3\envs\itk\lib\site-packages\pydicom\valuerep.py", line 564, in <listcomp>
    for comp in components]
  File "C:\Users\Amanda\AppData\Local\Continuum\anaconda3\envs\itk\lib\site-packages\pydicom\charset.py", line 129, in decode_string
    return value.decode(encodings[0])
LookupError: unknown encoding: Not Supplied

#### Versions
Platform: Windows-10-10.0.17763-SP0
Python Version: Python 3.6.4 |Anaconda, Inc.| (default, Mar 12 2018, 20:20:50) [MSC v.1900 64 bit (AMD64)]
pydicom Version: pydicom 1.2.2

