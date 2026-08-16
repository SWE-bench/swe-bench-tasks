LUT Descriptor tag with no value yields TypeError
**Describe the bug**
I have a DICOM image with the following tag (copied from ImageJ)

```
0028,1101  Red Palette Color Lookup Table Descriptor: 
```

which corresponds to the raw data element, produced by [`DataElement_from_raw`](https://github.com/pydicom/pydicom/blob/v1.4.1/pydicom/dataelem.py#L699):
```
RawDataElement(tag=(0028, 1101), VR='US', length=0, value=None, value_tell=1850, is_implicit_VR=False, is_little_endian=True)
```

Because this tag is matched by the [LUT Descriptor tags](https://github.com/pydicom/pydicom/blob/v1.4.1/pydicom/dataelem.py#L696) and the value is empty (`None`), the [following line](https://github.com/pydicom/pydicom/blob/v1.4.1/pydicom/dataelem.py#L761):
```
if raw.tag in _LUT_DESCRIPTOR_TAGS and value[0] < 0:
```
results in 
```
TypeError: 'NoneType' object is not subscriptable
```

**Expected behavior**

Given that I discovered this by parsing what seems to be a set of faulty DICOMs (mangled pixel data), I'm not sure if an error should be raised if the colour attribute value is not provided.

However, given that `value` can be `None` for other tags, the simple fix is

```python
try:
    if raw.tag in _LUT_DESCRIPTOR_TAGS and value[0] < 0:
        # We only fix the first value as the third value is 8 or 16
        value[0] += 65536
except TypeError:
    pass
```

(or test if `value` is iterable).

**Your environment**
```
Darwin-19.3.0-x86_64-i386-64bit
Python  3.7.6 | packaged by conda-forge | (default, Jan  7 2020, 22:05:27)
[Clang 9.0.1 ]
pydicom  1.4.1
```

Many thanks!
