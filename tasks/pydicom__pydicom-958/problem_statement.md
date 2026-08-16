Encoding to ISO 2022 IR 159 doesn't work
<!-- Instructions For Filing a Bug: https://github.com/pydicom/pydicom/blob/master/CONTRIBUTING.md#filing-bugs -->

#### Description
Encoding to ISO 2022 IR 159 doesn't work even if 'ISO 2022 IR 159' is passed to pydicom.charset.convert_encodings.

#### Steps/Code to Reproduce
ISO 2022 IR 159 is designed as supplement characters to ISO 2022 IR 87. So these characters are not frequent use. But person name sometimes contains them. In the following example, the letter of "鷗" is only in ISO 2022 IR 159. But we cannot encode them correctly. 

```
import pydicom

japanese_pn = u"Mori^Ogai=森^鷗外=もり^おうがい"
specific_character_sets = ["ISO 2022 IR 6", "ISO 2022 IR 87", "ISO 2022 IR 159"]
expect_encoded = (
    b"\x4d\x6f\x72\x69\x5e\x4f\x67\x61\x69\x3d\x1b\x24\x42\x3f"
    b"\x39\x1b\x28\x42\x5e\x1b\x24\x28\x44\x6c\x3f\x1b\x24\x42"
    b"\x33\x30\x1b\x28\x42\x3d\x1b\x24\x42\x24\x62\x24\x6a\x1b"
    b"\x28\x42\x5e\x1b\x24\x42\x24\x2a\x24\x26\x24\x2c\x24\x24"
    b"\x1b\x28\x42"
)

python_encodings = pydicom.charset.convert_encodings(specific_character_sets)
actual_encoded = pydicom.charset.encode_string(japanese_pn, python_encodings)

print("actual:{}".format(actual_encoded))
print("expect:{}".format(expect_encoded))
```
#### Expected Results
<!-- Please paste or describe the expected results.
Example: No error is thrown and the name of the patient is printed.-->
```
b'Mori^Ogai=\x1b$B?9\x1b(B^\x1b$(Dl?\x1b$B30\x1b(B=\x1b$B$b$j\x1b(B^\x1b$B$*$&$,$$\x1b(B'
```
#### Actual Results
<!-- Please paste or specifically describe the actual output or traceback.
(Use %xmode to deactivate ipython's trace beautifier)
Example: ```AttributeError: 'FileDataset' object has no attribute 'PatientID'```
-->
```
b'Mori^Ogai=?^??=??^????'
```

And the followin exception occurs.

```
/PATH/TO/MY/PYTHON/PACKAGES/pydicom/charset.py:488: UserWarning: Failed to encode value with encodings: iso8859, iso2022_jp, iso-2022-jp - using replacement characters in encoded string
  .format(', '.join(encodings)))
```

#### Versions
<!--
Please run the following snippet and paste the output below.
import platform; print(platform.platform())
import sys; print("Python", sys.version)
import pydicom; print("pydicom", pydicom.__version__)
-->
```
Linux-4.15.0-55-generic-x86_64-with-debian-buster-sid
Python 3.6.9 |Anaconda, Inc.| (default, Jul 30 2019, 19:07:31)
[GCC 7.3.0]
pydicom 1.3.0
```


<!-- Thanks for contributing! -->

