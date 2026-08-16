Print byte values for unknown VR during read
#### Description
If the dataset read fails due to an unknown VR then the exception message prints the VR bytes in a format that isn't useful for debugging.

#### Steps/Code to Reproduce
```python
from io import BytesIO
from pydicom.filereader import read_dataset
ds = read_dataset(BytesIO(b'\x08\x00\x01\x00\x04\x00\x00\x00\x00\x08\x00\x49'), False, True)
print(ds)
```

#### Expected Results
```
NotImplementedError: Unknown Value Representation: '32 31' in tag (0000, 0002)
```
#### Actual Results
```
File "<stdin>", line 1, in <module>
  File ".../pydicom/pydicom/dataset.py", line 1284, in __str__
    return self._pretty_str()
  File ".../pydicom/pydicom/dataset.py", line 1022, in _pretty_str
    for data_element in self:
  File ".../pydicom/pydicom/dataset.py", line 751, in __iter__
    yield self[tag]
  File ".../pydicom/pydicom/dataset.py", line 637, in __getitem__
    self[tag] = DataElement_from_raw(data_elem, character_set)
  File ".../pydicom/pydicom/dataelem.py", line 447, in DataElement_from_raw
    raise NotImplementedError("{0:s} in tag {1!r}".format(str(e), raw.tag))
NotImplementedError: Unknown Value Representation '' in tag (0008, 0001)
```
[Or see here for another example](https://user-images.githubusercontent.com/28559755/51027486-4abf4100-1591-11e9-8f44-a739b00ca300.PNG)


