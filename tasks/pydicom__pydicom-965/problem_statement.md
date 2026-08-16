Empty data elements with value representation SQ are set to None
**Describe the bug**
In the current `master`, empty data elements are not read correctly from files. The attribute value is set to `None` instead of `[]`.

**Expected behavior**
Create empty list `[]` for empty sequence, i.e., a sequence with zero items.

**Steps To Reproduce**
```python
import pydicom
ds = pydicom.Dataset()
ds.AcquisitionContextSequence = []
print(ds)
ds.is_little_endian = True
ds.is_implicit_VR = True
ds.save_as('/tmp/test.dcm')

reloaded_ds = pydicom.dcmread('/tmp/test.dcm', force=True)
print(reloaded_ds)
```
This prints:
```
(0040, 0555)  Acquisition Context Sequence   0 item(s) ----
...
TypeError: With tag (0040, 0555) got exception: object of type 'NoneType' has no len()
Traceback (most recent call last):
  File "/private/tmp/pydicom/pydicom/tag.py", line 30, in tag_in_exception
    yield
  File "/private/tmp/pydicom/pydicom/dataset.py", line 1599, in _pretty_str
    len(data_element.value)))
TypeError: object of type 'NoneType' has no len()
```

**Your environment**
```
Darwin-18.6.0-x86_64-i386-64bit
Python  3.7.3 (default, Mar 27 2019, 09:23:15)
[Clang 10.0.1 (clang-1001.0.46.3)]
pydicom  1.4.0.dev0
```
