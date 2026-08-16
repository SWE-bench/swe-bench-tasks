apply_voi_lut - unclear what it does if both WL/VOILUTFunction _and_ VOILUTSequence are present
https://pydicom.github.io/pydicom/dev/reference/generated/pydicom.pixel_data_handlers.util.html#pydicom.pixel_data_handlers.util.apply_voi_lut

Hi all,

I'm working with some mammo image (digital) that have both 
- window/level (0028,1050 0028,1051) plus VOILUTFunction (0028,1056) (set to SIGMOID) (set of 3 WL values)
- VOILUT sequences (0028, 3010)

specified.

Problem
---

It's unclear from the documentation when both a VOILUT (0028,3010) _and_ WL (0028,1051...) are present which is applied - the lut or the wl.

It just says if a LUT's present, it will apply that, and if a WL set is present it will apply that.

Questions
---

- If both LUT and WL are supplied, by the dicom standard, which should be applied?
- Separately to the above question about which is applied, if _both_ LUT and WL sequences are supplied, is there a way in `apply_voi_lut` to specify applying one or the other?  (ie force application of the WL instead of LUT etc)

- Also, if an image has a sequence of WL values rather than being single valued (so 0028,1050 & 0028,1051 are sequences), does the `index` parameter to `apply_voi_lut` apply to specify which in the sequence you want to use?

Thanks!

apply_voi_lut can't handle missing DICOM meta info
I have encountered two real life examples where `apply_voi_lut` does not handle corruption in DICOM meta fields

case 1:
```
(0028, 1050) Window Center                       DS: "128.0"
(0028, 1051) Window Width                        DS: "256.0"
(0028, 1052) Rescale Intercept                   DS: None
(0028, 1053) Rescale Slope                       DS: None
```
throws an exception

```
  File "python3.7/site-packages/pydicom/pixel_data_handlers/util.py", line 380, in apply_voi_lut
    y_min = y_min * ds.RescaleSlope + ds.RescaleIntercept
TypeError: unsupported operand type(s) for *: 'int' and 'NoneType' 
```


case 2:

```
(0028, 1050) Window Center                       DS: "2607.0"
(0028, 1051) Window Width                        DS: "2785.0"
(0028, 1052) Rescale Intercept                   DS: "0.0"
(0028, 1053) Rescale Slope                       DS: "1.0"
(0028, 1054) Rescale Type                        LO: 'US'
(0028, 2110) Lossy Image Compression             CS: '00'
(0028, 3010)  VOI LUT Sequence   1 item(s) ---- 
   (0028, 3002) LUT Descriptor                      SS: None
   (0028, 3003) LUT Explanation                     LO: 'Noramal'
   (0028, 3006) LUT Data                            OW: None
```

throws an exception

```
  File "python3.7/site-packages/pydicom/pixel_data_handlers/util.py", line 312, in apply_voi_lut
    nr_entries = item.LUTDescriptor[0] or 2**16
TypeError: 'NoneType' object is not subscriptable
```


So far I have handled this with:

```
    def _lut_convert(self):
        return apply_voi_lut(self.input_dicom.pixel_array, self.input_dicom)

    def _get_raw_data(self):

        # convert to presentation LUT
        try:
            data = self._lut_convert()
        # many things can be corrupted in the VOILUTSequence attribute,
        # fall back to default WC/WW conversion
        except Exception as e:
            try:
                if "VOILUTSequence" in self.input_dicom:
                    del self.input_dicom["VOILUTSequence"]
                    data = self._lut_convert()
            except Exception as e:
                raise InvalidImage(f"Could not convert to presentation LUT due to: {e}")
```

While the case 1 could be seen as an expected behavior (?), I imagine case 2 should be handled by WC/WW transformations if followed DICOM standard?









