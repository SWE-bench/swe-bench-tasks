Strings with Value Representation DS are too long
**Describe the bug**
Strings of Value Representation DS are restricted to a maximum length of 16 bytes according to [Part 5 Section 6.2](http://dicom.nema.org/medical/dicom/current/output/chtml/part05/sect_6.2.html#para_15754884-9ca2-4b12-9368-d66f32bc8ce1), but `pydicom.valuerep.DS` may represent numbers with more than 16 bytes.

**Expected behavior**
`pydicom.valuerep.DS` should create a string of maximum length 16, when passed a fixed point number with many decimals.

**Steps To Reproduce**
```python
len(str(pydicom.valuerep.DS(3.14159265358979323846264338327950288419716939937510582097)).encode('utf-8'))
len(str(pydicom.valuerep.DS("3.14159265358979323846264338327950288419716939937510582097")).encode('utf-8'))
```
returns `17` and `58`, respectively, instead of `16`.

**Your environment**
```
module       | version
------       | -------
platform     | macOS-10.15.6-x86_64-i386-64bit
Python       | 3.8.6 (default, Oct  8 2020, 14:06:32)  [Clang 12.0.0 (clang-1200.0.32.2)]
pydicom      | 2.0.0
gdcm         | _module not found_
jpeg_ls      | _module not found_
numpy        | 1.19.4
PIL          | 8.0.1
```
