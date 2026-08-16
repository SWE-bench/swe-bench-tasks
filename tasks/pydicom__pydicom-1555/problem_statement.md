Converting Dicom image to Png
**Describe the issue**
hi, i am trying to convert Dicom image to png but in case of some particular file i am getting this "list out of range error".

**Expected behavior**
dicom image converted to png pne

**Steps To Reproduce**
How to reproduce the issue. Please include:
1. A minimum working code sample
```
from pydicom import dcmread
def read_xray(path, voi_lut = True, fix_monochrome = True):
    dicom = dcmread(path, force=True)
    
    # VOI LUT (if available by DICOM device) is used to transform raw DICOM data to "human-friendly" view
    if voi_lut:
        data = apply_voi_lut(dicom.pixel_array, dicom)
    else:
        data = dicom.pixel_array
               
    # depending on this value, X-ray may look inverted - fix that:
    if fix_monochrome and dicom.PhotometricInterpretation == "MONOCHROME1":
        data = np.amax(data) - data
        
    data = data - np.min(data)
    data = data / np.max(data)
    data = (data * 255).astype(np.uint8)
        
    return data

img = read_xray('/content/a.5545da1153f57ff8425be6f4bc712c090e7e22efff194da525210c84aba2a947.dcm')
plt.figure(figsize = (12,12))
plt.imshow(img)
```
2. The traceback (if one occurred)
```
IndexError                                Traceback (most recent call last)
<ipython-input-13-6e53d7d16b90> in <module>()
     19     return data
     20 
---> 21 img = read_xray('/content/a.5545da1153f57ff8425be6f4bc712c090e7e22efff194da525210c84aba2a947.dcm')
     22 plt.figure(figsize = (12,12))
     23 plt.imshow(img)

2 frames
/usr/local/lib/python3.7/dist-packages/pydicom/multival.py in __getitem__(self, index)
     93         self, index: Union[slice, int]
     94     ) -> Union[MutableSequence[_ItemType], _ItemType]:
---> 95         return self._list[index]
     96 
     97     def insert(self, position: int, val: _T) -> None:

IndexError: list index out of range
```

3. Which of the following packages are available and their versions:
  * Numpy : latest as of 29th dec
  * Pillow : latest as of 29th dec
  * JPEG-LS : latest as of 29th dec
  * GDCM : latest as of 29th dec
4. The anonymized DICOM dataset (if possible).
image link : https://drive.google.com/file/d/1j13XTTPCLX-8e7FE--1n5Staxz7GGNWm/view?usp=sharing

**Your environment**
If you're using **pydicom 2 or later**, please use the `pydicom.env_info`
module to gather information about your environment and paste it in the issue:

```bash
$ python -m pydicom.env_info
```

For **pydicom 1.x**, please run the following code snippet and paste the
output.

```python
import platform, sys, pydicom
print(platform.platform(),
      "\nPython", sys.version,
      "\npydicom", pydicom.__version__)
```

