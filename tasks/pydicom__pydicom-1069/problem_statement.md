apply_color_lut() incorrect exception when missing RedPaletteColorLUTDescriptor
**Describe the bug**
`AttributeError` when used on a dataset without `RedPaletteColorLookupTableDescriptor `

**Expected behavior**
Should raise `ValueError` for consistency with later exceptions

**Steps To Reproduce**
```python
from pydicom.pixel_data_handlers.util import apply_color_lut
ds = dcmread("CT_small.dcm")
arr = ds.apply_color_lut(arr, ds)
```
```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File ".../pydicom/pixel_data_handlers/util.py", line 116, in apply_color_lut
    lut_desc = ds.RedPaletteColorLookupTableDescriptor
  File ".../pydicom/dataset.py", line 768, in __getattr__
    return object.__getattribute__(self, name)
AttributeError: 'FileDataset' object has no attribute 'RedPaletteColorLookupTableDescriptor'
```
