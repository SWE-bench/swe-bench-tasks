This is going to be difficult to troubleshoot without the original DICOMDIR dataset. Could you create an anonymised version of it using the following and attach it please?

```python
from pydicom import dcmread

ds = dcmread("DICOMDIR")
for item in ds.DirectoryRecordSequence:
    if item.DirectoryRecordType == "PATIENT":
        item.PatientName = "X" * len(item.PatientName)
        item.PatientID = "X" * len(item.PatientID)

ds.save_as("DICOMDIR_anon", write_like_original=True)
```
If there are any other identifying elements in the DICOMDIR then just anonymise them using the same method of overwriting with a value of the same length.
I can't reproduce with:
```python
from tempfile import TemporaryDirectory
from pathlib import Path
import shutil

from pydicom.data import get_testdata_file
from pydicom.fileset import FileSet


# Copy test file set to temporary directory
t = TemporaryDirectory()
src = Path(get_testdata_file("DICOMDIR")).parent
dst = Path(t.name)

shutil.copyfile(src / 'DICOMDIR', dst / 'DICOMDIR')
shutil.copytree(src / "77654033", dst / "77654033")
shutil.copytree(src / "98892003", dst / "98892003")
shutil.copytree(src / "98892001", dst / "98892001")

# Load
fs = FileSet(dst / "DICOMDIR")
# Write without changes
fs.write(use_existing=True)
```
I strongly suspect there's a bad offset being written in your DICOMDIR for some reason, but without seeing the original I can't really do much.