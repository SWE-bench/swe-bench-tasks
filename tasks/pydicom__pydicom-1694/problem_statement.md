Dataset.to_json_dict can still generate exceptions when suppress_invalid_tags=True
**Describe the bug**
I'm using `Dataset.to_json_dict(suppress_invalid_tags=True)` and can live with losing invalid tags.  Unfortunately, I can still trigger an exception with something like  `2.0` in an `IS` field.

**Expected behavior**
to_json_dict shouldn't throw an error about an invalid tag when `suppress_invalid_tags` is enabled.

My thought was simply to move the `data_element = self[key]` into the try/catch block that's right after it.

**Steps To Reproduce**

Traceback:
```
  File "dicom.py", line 143, in create_dict
    json_ds = ds.to_json_dict(suppress_invalid_tags=True)
  File "/usr/lib/python3/dist-packages/pydicom/dataset.py", line 2495, in to_json_dict
    data_element = self[key]
  File "/usr/lib/python3/dist-packages/pydicom/dataset.py", line 939, in __getitem__
    self[tag] = DataElement_from_raw(elem, character_set, self)
  File "/usr/lib/python3/dist-packages/pydicom/dataelem.py", line 859, in DataElement_from_raw
    value = convert_value(vr, raw, encoding)
  File "/usr/lib/python3/dist-packages/pydicom/values.py", line 771, in convert_value
    return converter(byte_string, is_little_endian, num_format)
  File "/usr/lib/python3/dist-packages/pydicom/values.py", line 348, in convert_IS_string
    return MultiString(num_string, valtype=pydicom.valuerep.IS)
  File "/usr/lib/python3/dist-packages/pydicom/valuerep.py", line 1213, in MultiString
    return valtype(splitup[0])
  File "/usr/lib/python3/dist-packages/pydicom/valuerep.py", line 1131, in __new__
    raise TypeError("Could not convert value to integer without loss")
TypeError: Could not convert value to integer without loss
```

**Your environment**
python 3.7, pydicom 2.3


