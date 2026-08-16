Some notes for myself:

* The EOT is optional and intended to support users where there are multiple compressed frames and the total length of all the frames exceeds the `2**32 - 1` limit available in the BOT item lengths. 
* Only 1 fragment per frame is allowed with an EOT
* The *Extended Table Offset Lengths* is the length (in bytes) of each compressed frame
* It's not usable where each compressed frame is larger than `2**32 - 1` due to the limit in the 4-byte (FFFE,E000) Item Tag length (who has 4 GB compressed images anyway?)

Relevant links: [google groups issue](https://groups.google.com/forum/?nomobile=true#!searchin/comp.protocols.dicom/extended$20offset|sort:date/comp.protocols.dicom/piMk2TmcyEg/daCk33zDBwAJ), [Image Pixel module](http://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.7.6.3.html), [BOT](http://dicom.nema.org/medical/dicom/current/output/chtml/part05/sect_A.4.html)

Implementation shouldn't be difficult, something along the lines of:
```python
from struct import pack
from pydicom.encaps import encapsulate

frame_data: List[bytes] = [...]
ds.PixelData = encapsulate(frame_data, has_bot=False, fragments_per_frame=1)

frame_lengths = [len(f) for f in frame_data]
frame_offsets = [0]
for ii, length in enumerate(frame_lengths[:-1]):
    frame_offsets .append(frame_offsets [ii] + length + 8)
ds.ExtendedOffsetTable =  pack("<{len(frame_offsets )}Q", *frame_offsets )
ds.ExtendedOffsetTableLengths = pack("<{len(frame_lengths)}Q", *frame_lengths)
```

Maybe just add a helper function to ensure conformance? And add a check to `encapsulate()` for data that's too long.
```python
from pydicom.encaps import encapsulate_extended

out: Tuple[bytes, bytes, bytes] = encapsulate_extended(frame_data)
ds.PixelData = out[0]
ds.ExtendedOffsetTable = out[1]
ds.ExtendedOffsetTableLengths = out[2]
```

Parsing should already be handled correctly by `generate_pixel_data()` since it's 1 frame per fragment.