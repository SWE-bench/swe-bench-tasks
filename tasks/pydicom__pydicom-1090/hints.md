Of course, it's entirely possible I'm just not using the library properly.
Regardless, here are my original and generated files, as well as the reproduction steps:
[write_deflated_file.zip](https://github.com/pydicom/pydicom/files/4557981/write_deflated_file.zip)

Thanks for your attention in this. Assuming it's deemed to be a valid bug, I'd be happy to contribute to the development of a solution. (My initial thought is that the Transfer Syntax should be respected and that the file should be written deflated, but I've not investigated deeply.)
Try setting `ds.is_explicit_VR = True` before saving. Changing the Transfer Syntax isn't enough to control the encoding of the written dataset.

We should probably add a warning for when the transfer syntax doesn't match `is_implicit_VR` and `is_little_endian`...

I'm not sure about deflated off hand, I'll need to check
Thanks, @scaramallion. That had no effect. The output is exactly the same.

I fear I may not have been clear. I never did change the Transfer Syntax. It stayed at Deflated Explicit VR Little Endian, just as it was in the source…
We don't have anything out-of-the-box for writing deflated, this should work:
```python
import zlib

from pydicom import dcmread
from pydicom.data import get_testdata_file
from pydicom.filebase import DicomBytesIO
from pydicom.filewriter import write_file_meta_info, write_dataset
from pydicom.uid import DeflatedExplicitVRLittleEndian

ds = dcmread(get_testdata_file("CT_small.dcm"))
ds.file_meta.TransferSyntaxUID = DeflatedExplicitVRLittleEndian

with open('deflated.dcm', 'wb') as f:
    # Write preamble and DICM marker
    f.write(b'\x00' * 128)
    f.write(b'DICM')
    # Write file meta information elements
    write_file_meta_info(f, ds.file_meta)

    # Encode the dataset
    bytesio = DicomBytesIO()
    bytesio.is_little_endian = True
    bytesio.is_implicit_VR = False
    write_dataset(bytesio, ds)

    # Compress the encoded data and write to file
    compressor = zlib.compressobj(wbits=-zlib.MAX_WBITS)
    deflated = compressor.compress(bytesio.parent.getvalue())
    deflated += compressor.flush()
    if len(deflated) %2:
        deflated += b'\x00'

    f.write(deflated)

ds = dcmread('deflated.dcm')
print(ds)
```
Thanks, @scaramallion. Are you looking for a contribution, or are you thinking the design would be would be too complicated for an enthusiastic experienced programmer but first-time pydicomer?
(I'm assuming this would eventually just become automatic behaviour whenever saving something with the matching Transfer Syntax…)
I think this is definitely a contribution a first-timer could make, take a look at `filewriter.dcmwrite()`, if you add a check for the deflated transfer syntax around [line 968](https://github.com/pydicom/pydicom/blob/master/pydicom/filewriter.py#L968) then encode and deflate accordingly.
> this is definitely a contribution a first-timer could make

Then sign me up! Assuming you don't need it by tomorrow. (I won't be super slow. It's just that it's nearly bedtime and I have a day job.)

There's no rush, we (nearly) all have day jobs 