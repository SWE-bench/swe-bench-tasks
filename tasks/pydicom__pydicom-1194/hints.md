```python
>>> from pydicom import dcmread
>>> dcmread("CT_S1_001.dcm")
Traceback (most recent call last):
  File ".../pydicom/tag.py", line 30, in tag_in_exception
    yield
  File ".../pydicom/filewriter.py", line 555, in write_dataset
    write_data_element(fp, dataset.get_item(tag), dataset_encoding)
  File ".../pydicom/dataset.py", line 1060, in get_item
    return self[key]
  File ".../pydicom/dataset.py", line 878, in __getitem__
    self[tag] = correct_ambiguous_vr_element(
  File ".../pydicom/filewriter.py", line 160, in correct_ambiguous_vr_element
    _correct_ambiguous_vr_element(elem, ds, is_little_endian)
  File ".../pydicom/filewriter.py", line 86, in _correct_ambiguous_vr_element
    elem_value = elem.value if elem.VM == 1 else elem.value[0]
TypeError: 'NoneType' object is not subscriptable
```
Issue occurs because the dataset is Implicit VR and the *Smallest Image Pixel Value* is ambiguous but empty,