Generators in encaps don't handle single fragment per frame correctly with no BOT value
#### Description
Generators in `encaps.py` handling of encapsulated pixel data incorrect when the Basic Offset Table has no value and each frame is a single fragment.

#### Steps/Code to Reproduce
```python
from pydicom import dcmread
from pydicom.encaps import generate_pixel_data_frame

fpath = 'pydicom/data/test_files/emri_small_jpeg_2k_lossless.dcm'
ds = dcmread(fpath)
ds.NumberOfFrames  # 10
frame_generator = generate_pixel_data_frame(ds.PixelData)
next(frame_generator)
next(frame_generator) # StopIteration raised
```

#### Expected Results
All 10 frames of the pixel data should be accessible.

#### Actual Results
Only the first frame is accessible.
[MRG] Some pixel handlers will not decode multiple fragments per frame


Added test cases to demonstrate failures for jpeg ls with multiple fragments per frame.  The test files were created with dcmtk 3.6.1 using dcmcjpls +fs 1. One file has an offset table, the other does not.

#### Reference Issue
See #685 


#### What does this implement/fix? Explain your changes.
These test cases show that the pixel decoders (jpeg and jpeg_ls most likely) will not handle multiple fragments per frame.

No fix yet...

Any suggestions?
