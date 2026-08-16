Pixel Representation attribute should be optional for pixel data handler
**Describe the bug**
The NumPy pixel data handler currently [requires the Pixel Representation attribute](https://github.com/pydicom/pydicom/blob/8da0b9b215ebfad5756051c891def88e426787e7/pydicom/pixel_data_handlers/numpy_handler.py#L46). This is problematic, because in case of Float Pixel Data or Double Float Pixel Data the attribute shall be absent. Compare [Floating Point Image Pixel Module Attributes](http://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.7.6.24.html) versus [Image Pixel Description Macro Attributes](http://dicom.nema.org/medical/dicom/current/output/chtml/part03/sect_C.7.6.3.html#table_C.7-11c)

**Expected behavior**
I would expect the `Dataset.pixel_array` property to be able to decode a Float Pixel Data or Double Float Pixel Data element without presence of the Pixel Representation element in the metadata.

**Steps To Reproduce**
```python
import numpy as np
from pydicom.dataset import Dataset, FileMetaDataset


ds = Dataset()
ds.file_meta = FileMetaDataset()
ds.file_meta.TransferSyntaxUID = '1.2.840.10008.1.2.1'

ds.BitsAllocated = 32
ds.SamplesPerPixel = 1
ds.Rows = 5
ds.Columns = 5
ds.PhotometricInterpretation = 'MONOCHROME2'

pixel_array = np.zeros((ds.Rows, ds.Columns), dtype=np.float32)
ds.FloatPixelData = pixel_array.flatten().tobytes()

np.array_equal(ds.pixel_array, pixel_array)
```
