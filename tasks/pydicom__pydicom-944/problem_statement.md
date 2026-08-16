Embedded Null character
<!-- Instructions For Filing a Bug: https://github.com/pydicom/pydicom/blob/master/CONTRIBUTING.md#filing-bugs -->

#### Description
<!-- Example: Attribute Error thrown when printing (0x0010, 0x0020) patient Id> 0-->
---------------------------------------------------------------------------
KeyError                                  Traceback (most recent call last)
~/anaconda3/lib/python3.7/site-packages/pydicom/charset.py in convert_encodings(encodings)
    624         try:
--> 625             py_encodings.append(python_encoding[encoding])
    626         except KeyError:

KeyError: 'ISO_IR 100\x00'

During handling of the above exception, another exception occurred:

ValueError                                Traceback (most recent call last)
<ipython-input-12-605c3c3edcf4> in <module>
      4 print(filename)
      5 dcm = pydicom.dcmread(filename,force=True)
----> 6 dcm = pydicom.dcmread('/home/zhuzhemin/XrayKeyPoints/data/10-31-13_11H18M20_3674972_FACE_0_SC.dcm',force=True)

~/anaconda3/lib/python3.7/site-packages/pydicom/filereader.py in dcmread(fp, defer_size, stop_before_pixels, force, specific_tags)
    848     try:
    849         dataset = read_partial(fp, stop_when, defer_size=defer_size,
--> 850                                force=force, specific_tags=specific_tags)
    851     finally:
    852         if not caller_owns_file:

~/anaconda3/lib/python3.7/site-packages/pydicom/filereader.py in read_partial(fileobj, stop_when, defer_size, force, specific_tags)
    726         dataset = read_dataset(fileobj, is_implicit_VR, is_little_endian,
    727                                stop_when=stop_when, defer_size=defer_size,
--> 728                                specific_tags=specific_tags)
    729     except EOFError:
    730         pass  # error already logged in read_dataset

~/anaconda3/lib/python3.7/site-packages/pydicom/filereader.py in read_dataset(fp, is_implicit_VR, is_little_endian, bytelength, stop_when, defer_size, parent_encoding, specific_tags)
    361     try:
    362         while (bytelength is None) or (fp.tell() - fp_start < bytelength):
--> 363             raw_data_element = next(de_gen)
    364             # Read data elements. Stop on some errors, but return what was read
    365             tag = raw_data_element.tag

~/anaconda3/lib/python3.7/site-packages/pydicom/filereader.py in data_element_generator(fp, is_implicit_VR, is_little_endian, stop_when, defer_size, encoding, specific_tags)
    203                 # Store the encoding value in the generator
    204                 # for use with future elements (SQs)
--> 205                 encoding = convert_encodings(encoding)
    206 
    207             yield RawDataElement(tag, VR, length, value, value_tell,

~/anaconda3/lib/python3.7/site-packages/pydicom/charset.py in convert_encodings(encodings)
    626         except KeyError:
    627             py_encodings.append(
--> 628                 _python_encoding_for_corrected_encoding(encoding))
    629 
    630     if len(encodings) > 1:

~/anaconda3/lib/python3.7/site-packages/pydicom/charset.py in _python_encoding_for_corrected_encoding(encoding)
    664     # fallback: assume that it is already a python encoding
    665     try:
--> 666         codecs.lookup(encoding)
    667         return encoding
    668     except LookupError:

ValueError: embedded null character
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
import pydicom
dcm = pydicom.dcmread('/home/zhuzhemin/XrayKeyPoints/data/10-31-13_11H18M20_3674972_FACE_0_SC.dcm')

#### Expected Results
<!-- Please paste or describe the expected results.
Example: No error is thrown and the name of the patient is printed.-->
No error
I used dcmread function in matlab to read the same file and it was ok. So it should not be the problem of the file.
#### Actual Results
<!-- Please paste or specifically describe the actual output or traceback.
(Use %xmode to deactivate ipython's trace beautifier)
Example: ```AttributeError: 'FileDataset' object has no attribute 'PatientID'```
-->
Error: Embedded Null character
#### Versions
<!--
Please run the following snippet and paste the output below.
import platform; print(platform.platform())
import sys; print("Python", sys.version)
import pydicom; print("pydicom", pydicom.__version__)
-->
1.3.0

<!-- Thanks for contributing! -->

