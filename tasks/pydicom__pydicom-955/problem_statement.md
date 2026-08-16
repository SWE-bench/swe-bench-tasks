LUT Descriptor values don't follow standard
**Describe the bug**
(0028,3002) [LUT Descriptor](http://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.11.html#sect_C.11.1.1) has VM = 3, with value as `[number of entries in LUT, first stored pixel value mapped, LUT entry bit depth]`. The VR for the element is ambiguous and may be US or SS depending on the value of (0028,0103) Pixel Representation, however this only affects the second value, not the first or last which are always US.

The problem is that a Pixel Representation value of 1 (i.e. 2s complement) gives a LUT Descriptor value 1 as signed when it should always be unsigned.

> Since LUT Descriptor (0028,3002) is multi-valued, in an Explicit VR Transfer Syntax, only one value representation (US or SS) may be specified, even though the first and third values are always by definition interpreted as unsigned. The explicit VR actually used is dictated by the VR needed to represent the second value, which will be consistent with Pixel Representation (0028,0103).

Also affects Red/Green/Blue Palette Color Lookup Table Descriptor.

**Steps To Reproduce**
```python
from pydicom import dcmread
from pydicom.filebase import DicomBytesIO

# Explicit VR: SS
lut = b'\x28\x00\x02\x30\x53\x53\x06\x00\x00\xf5\x00\xf8\x10\x00'

bs = DicomBytesIO(lut)
bs.is_little_endian = True
bs.is_implicit_VR = False

ds = dcmread(bs, force=True)
assert ds.LUTDescriptor == [62720, -2048, 16]
```

**Your environment**
Affects current `master`

