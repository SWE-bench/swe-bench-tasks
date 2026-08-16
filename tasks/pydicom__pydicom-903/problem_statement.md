Handling of DS too long to be encoded in explicit encoding
<!-- Instructions For Filing a Bug: https://github.com/pydicom/pydicom/blob/master/CONTRIBUTING.md#filing-bugs -->

#### Description
This is probably not a bug, but I'm not sure about the wanted behavior.
An RTPlan dataset encoded as Little Endian Implicit contains multiple values in the DS tag DHV Data (3004,0058) with an overall length not fitting into 2 bytes. Trying to write this as explicit Little Endian fails with an exception (`"ushort format requires 0 &lt;= number &lt;= (0x7fff * 2 + 1)"`) which is raised by the `pack` call in `write_leUS` while trying to write the length.

The standard says for this case in PS3.5, Table 6.2-1 (for VR DS):
```
Note
Data Elements with multiple values using this VR may not be properly encoded if Explicit-VR transfer syntax is used and the VL of this attribute exceeds 65534 bytes.
```
So, as I understand it, this is valid DICOM, that cannot be converted to explicit encoding without data loss.
The question is how to handle this. What comes to mind:
- truncate the value and log a warning
- raise a meaningful exception
- adapt the behavior depending on some config setting

Any thoughts?

<!-- Example: Attribute Error thrown when printing (0x0010, 0x0020) patient Id> 0-->

#### Steps/Code to Reproduce
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

#### Actual Results
<!-- Please paste or specifically describe the actual output or traceback.
(Use %xmode to deactivate ipython's trace beautifier)
Example: ```AttributeError: 'FileDataset' object has no attribute 'PatientID'```
-->

#### Versions
<!--
Please run the following snippet and paste the output below.
import platform; print(platform.platform())
import sys; print("Python", sys.version)
import pydicom; print("pydicom", pydicom.__version__)
-->


<!-- Thanks for contributing! -->

