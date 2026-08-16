Also tried following code to get the byte string, but same error.
1. data=array.array('L', indexData).tostring()  # to convert to long -> same error
2. data=array.array('Q', indexData).tostring()  # to convert to long long -> same error


O* VRs should be `bytes`. Use `array.tobytes()` instead of `tostring()`?

Also, in the future if have an issue it's much more helpful if you post the full traceback rather than the error since we can look at it to figure out where in the code the exception is occurring.

It would also help if you posted the version of Python you're using. 

This works fine for me with Python 3.9 and pydicom 2.1.2:
```python
from pydicom import Dataset
import array

arr = array.array('H', range(10))
ds = Dataset()
ds.is_little_endian = True
ds.is_implicit_VR = False
ds.LongTrianglePointIndexList = arr.tobytes()
print(ds["LongTrianglePointIndexList"].VR)  # 'OL'
ds.save_as('temp.dcm')
```
This also works fine:
```python
ds = Dataset()
ds.add_new(0x00660040, 'OL', arr.tobytes())
```
Thank you for the answer.
Unfortunately the error still persists with above code.
Please find the attached detailed error.
[error.txt](https://github.com/pydicom/pydicom/files/6661451/error.txt)

One more information is that the 'ds' is actually read from a file in the disk (ds=pydicom.read_file(filename)). 
and this byte array is stored under the following sequence
ds[0x0066,0x0002][0][0x0066,0x0013][0][0x0066,0x0028][0][0x0066,0x0040] = arr.tobytes()

pydicom - 2.0.0.0
python - 3.6.4

Thank you.
Could you post a minimal code sample that reproduces the issue please?

If you're using something like this:
`ds[0x0066,0x0002][0][0x0066,0x0013][0][0x0066,0x0028][0][0x0066,0x0040] = arr.tobytes()`

Then you're missing the `.value` assignment:
`ds[0x0066,0x0002][0][0x0066,0x0013][0][0x0066,0x0028][0][0x0066,0x0040].value = arr.tobytes()`
Hello,
above code line I just mentioned to give an idea where the actual data is stored (tree level).

Please find the actual code used below,
```python
import pydicom
from pydicom.sequence import Sequence
from pydicom.dataelem import DataElement
from pydicom.dataset import Dataset

ds = pydicom.read_file(filename)
surfaceSeq= ds[0x0066,0x0002]

#// read existing sequence items in the dataset
seqlist=[]
for n in surfaceSeq:
    seqlist.append(n)

newDs = Dataset()
 
surfaceMeshPrimitiveSq = Dataset()
lineSeq = Dataset()
indexData = list(range(1,100))
indexData = array.array('H', indexData)
indexData = indexData.tobytes()
lineSeq.add_new(0x00660040, 'OL', indexData) 
surfaceMeshPrimitiveSq.add_new(0x00660028, 'SQ', [lineSeq])
newDs.add_new(0x00660013, 'SQ', [surfaceMeshPrimitiveSq])

#add the new sequnce item to the list
seqlist.append(newDs)
ds[0x0066,0x0002] = DataElement(0x00660002,"SQ",seqlist)
ds.save_as(filename)
```
OK, I can reproduce with:
```python

import array

from pydicom import Dataset
from pydicom.uid import ExplicitVRLittleEndian

ds = Dataset()
ds.file_meta = Dataset()
ds.file_meta.TransferSyntaxUID = ExplicitVRLittleEndian

b = array.array('H', range(100)).tobytes()

ds.LongPrimitivePointIndexList = b
ds.save_as('1421.dcm')
```
And `print(ds)` gives:
```
(0066, 0040) Long Primitive Point Index List     OL: [b'\x00\x00\x01\x00\x02\x00\x03\x00\x04\x00\x05\x00\x06\x00\x07\x00\x08\x00\t\x00\n\x00\x0b\x00\x0c\x00\r\x00\x0e\x00\x0f\x00\x10\x00\x11\x00\x12\x00\x13\x00\x14\x00\x15\x00\x16\x00\x17\x00\x18\x00\x19\x00\x1a\x00\x1b\x00\x1c\x00\x1d\x00\x1e\x00\x1f\x00 \x00!\x00"\x00#\x00$\x00%\x00&\x00\'\x00(\x00)\x00*\x00+\x00,\x00-\x00.\x00/\x000\x001\x002\x003\x004\x005\x006\x007\x008\x009\x00:\x00;\x00<\x00=\x00>\x00?\x00@\x00A\x00B\x00C\x00D\x00E\x00F\x00G\x00H\x00I\x00J\x00K\x00L\x00M\x00N\x00O\x00P\x00Q\x00R\x00S\x00T\x00U\x00V\x00W\x00X\x00Y\x00Z\x00[\x00', b'\x00]\x00^\x00_\x00`\x00a\x00b\x00c\x00']
```
I think this is because the byte value is hitting the hex for the backslash character during assignment. Ouch, that's kinda nasty.