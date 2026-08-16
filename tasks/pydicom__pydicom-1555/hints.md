```
Traceback (most recent call last):
  File "pyd1554.py", line 29, in <module>
    img = read_xray('datasets/pyd1554.dcm')
  File "...pyd1554.py", line 14, in read_xray
    data = apply_voi_lut(dicom.pixel_array, dicom)
  File ".../pydicom/pixel_data_handlers/util.py", line 348, in apply_voi_lut
    ds.VOILUTSequence[0].get('LUTDescriptor', None),
  File ".../pydicom/multival.py", line 95, in __getitem__
    return self._list[index]
IndexError: list index out of range
```
The *VOI LUT Sequence* is empty, which is probably non-conformant but I can't actually tell what the *SOP Class UID* is (your anonymiser is weird, but probably mammo).

Here's the whole (also weird) *VOI LUT Sequence* (in hex):
```
       Tag | SQ  |     | Length    | Seq end delimiter     |
28 00 10 30 53 51 00 00 FF FF FF FF FE FF DD E0 00 00 00 00
```

I might add a check for an empty sequence in `apply_voi_lut` (and the other visualisation functions).
