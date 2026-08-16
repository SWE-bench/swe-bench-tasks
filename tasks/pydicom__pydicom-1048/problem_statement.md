dcmread cannot handle pathlib.Path objects
**Describe the bug**
The `dcmread()` currently fails when passed an instance of `pathlib.Path`. The problem is the following line:
https://github.com/pydicom/pydicom/blob/8b0bbaf92d7a8218ceb94dedbee3a0463c5123e3/pydicom/filereader.py#L832

**Expected behavior**
`dcmread()` should open and read the file to which the `pathlib.Path` object points.

The line above should probably be:
```python
if isinstance(fp, (str, Path)):
````

**Steps To Reproduce**
```python
from pathlib import Path
from pydicom.filereader import dcmread

dcm_filepath = Path('path/to/file')
dcmread(dcm_filepath)
```
