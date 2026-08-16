Wrong encoding occurs if the value 1 of SpecificCharacterSets is ISO 2022 IR 13.
<!-- Instructions For Filing a Bug: https://github.com/pydicom/pydicom/blob/master/CONTRIBUTING.md#filing-bugs -->

#### Description
All Japanese characters are encoded into shift_jis if the value 1 of SpecificCharacterSets (0x0008, 0x0005) is  ISO 2022 IR 13.

#### Steps/Code to Reproduce
The japanese_pn and expect_encoded in the following code came from 
[H.3.2 Value 1 of Attribute Specific Character Set (0008,0005) is ISO 2022 IR 13.](http://dicom.nema.org/medical/dicom/2015b/output/chtml/part05/sect_H.3.2.html)

```py
import pydicom

japanese_pn = u"ﾔﾏﾀﾞ^ﾀﾛｳ=山田^太郎=やまだ^たろう"
specific_character_sets = ["ISO 2022 IR 13", "ISO 2022 IR 87"]
expect_encoded = (
    b"\xd4\xcf\xc0\xde\x5e\xc0\xdb\xb3\x3d\x1b\x24\x42\x3b\x33"
    b"\x45\x44\x1b\x28\x4a\x5e\x1b\x24\x42\x42\x40\x4f\x3a\x1b"
    b"\x28\x4a\x3d\x1b\x24\x42\x24\x64\x24\x5e\x24\x40\x1b\x28"
    b"\x4a\x5e\x1b\x24\x42\x24\x3f\x24\x6d\x24\x26\x1b\x28\x4a"
)

python_encodings = pydicom.charset.convert_encodings(specific_character_sets)
actual_encoded = pydicom.charset.encode_string(japanese_pn, python_encodings)

print("actual:{}".format(actual_encoded))
print("expect:{}".format(expect_encoded))
```
<!--
Example:
```py
from io import BytesIO
from pydicom import dcmread

bytestream = b'\x02\x00\x02\x00\x55\x49\x16\x00\x31\x2e\x32\x2e\x38\x34\x30\x2e\x31' \
             b'\x30\x30\x30\x38\x2e\x35\x2e\x31\x2e\x31\x2e\x39\x00\x02\x00\x10\x00' \
             b'\x55\x49\x12\x00\x31\x2e\x32\x2e\x38\x34\x30\x2e\x31\x30\x30\x30\x38' \
             b'\x2e\x31\x2e\x32\x00\x20\x20\x10\x00\x02\x00\x00\x00\x01\x00\x20\x20' \
             b'\x20\x00\x06\x00\x00\x00\x4e\x4f\x52\x4d\x41\x4c'

fp = BytesIO(bytestream)
ds = dcmread(fp, force=True)

print(ds.PatientID)
```
If the code is too long, feel free to put it in a public gist and link
it in the issue: https://gist.github.com

When possible use pydicom testing examples to reproduce the errors. Otherwise, provide
an anonymous version of the data in order to replicate the errors.
-->

#### Expected Results
<!-- Please paste or describe the expected results.
Example: No error is thrown and the name of the patient is printed.-->
```
b'\xd4\xcf\xc0\xde^\xc0\xdb\xb3=\x1b$B;3ED\x1b(J^\x1b$BB@O:\x1b(J=\x1b$B$d$^$@\x1b(J^\x1b$B$?$m$&\x1b(J'
```

#### Actual Results
<!-- Please paste or specifically describe the actual output or traceback.
(Use %xmode to deactivate ipython's trace beautifier)
Example: ```AttributeError: 'FileDataset' object has no attribute 'PatientID'```
-->
```
b'\xd4\xcf\xc0\xde^\xc0\xdb\xb3=\x8eR\x93c^\x91\xbe\x98Y=\x82\xe2\x82\xdc\x82\xbe^\x82\xbd\x82\xeb\x82\xa4'
```

#### Versions
<!--
Please run the following snippet and paste the output below.
import platform; print(platform.platform())
import sys; print("Python", sys.version)
import pydicom; print("pydicom", pydicom.__version__)
-->
```
Linux-4.15.0-50-generic-x86_64-with-debian-buster-sid
Python 3.6.8 |Anaconda, Inc.| (default, Dec 30 2018, 01:22:34)
[GCC 7.3.0]
pydicom 1.2.2
```

<!-- Thanks for contributing! -->

