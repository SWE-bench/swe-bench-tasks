Error : a bytes-like object is required, not 'MultiValue'
Hello,

I am getting following error while updating the tag LongTrianglePointIndexList (0066,0040),
**TypeError: a bytes-like object is required, not 'MultiValue'**

I noticed that the error  gets produced only when the VR is given as "OL" , works fine with "OB", "OF" etc.

sample code (assume 'lineSeq' is the dicom dataset sequence):
```python
import pydicom
import array
data=list(range(1,10))
data=array.array('H', indexData).tostring()  # to convert to unsigned short
lineSeq.add_new(0x00660040, 'OL', data)   
ds.save_as("mydicom")
```
outcome: **TypeError: a bytes-like object is required, not 'MultiValue'**

using version - 2.0.0.0

Any help is appreciated.

Thank you
