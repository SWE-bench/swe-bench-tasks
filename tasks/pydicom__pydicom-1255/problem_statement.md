Mypy errors
**Describe the bug**
Several of the type hints are problematic and result in mypy errors.

One example:

```none
cat << EOF > /tmp/test.py
from pydicom import Dataset, dcmread

dataset = Dataset()
dataset.Rows = 10
dataset.Columns = 20
dataset.NumberOfFrames = "5"

assert int(dataset.NumberOfFrames) == 5

filename = '/tmp/test.dcm'
dataset.save_as(str(filename))

dataset = dcmread(filename)

assert int(dataset.NumberOfFrames) == 5
EOF
```

```none
mypy /tmp/test.py
/tmp/test.py:15: error: No overload variant of "int" matches argument type "object"
/tmp/test.py:15: note: Possible overload variant:
/tmp/test.py:15: note:     def int(self, x: Union[str, bytes, SupportsInt, _SupportsIndex] = ...) -> int
/tmp/test.py:15: note:     <1 more non-matching overload not shown>
Found 1 error in 1 file (checked 1 source file)
```

**Expected behavior**
Mypy should not report any errors.

**Steps To Reproduce**
See above

**Your environment**
```none
python -m pydicom.env_info
module       | version
------       | -------
platform     | macOS-10.15.6-x86_64-i386-64bit
Python       | 3.8.6 (default, Oct  8 2020, 14:06:32)  [Clang 12.0.0 (clang-1200.0.32.2)]
pydicom      | 2.1.0
gdcm         | _module not found_
jpeg_ls      | _module not found_
numpy        | 1.19.3
PIL          | 8.0.1
```
ImportError: cannot import name 'NoReturn'
**Describe the bug**
throw following excetion when import pydicom package:
```
xxx/python3.6/site-packages/pydicom/filebase.py in <module>
5 from struct import unpack, pack
      6 from types import TracebackType
----> 7 from typing import (
      8     Tuple, Optional, NoReturn, BinaryIO, Callable, Type, Union, cast, TextIO,
      9     TYPE_CHECKING, Any

ImportError: cannot import name 'NoReturn'
```

**Expected behavior**
imort pydicom sucessfully

**Steps To Reproduce**
How to reproduce the issue. Please include a minimum working code sample, the
traceback (if any) and the anonymized DICOM dataset (if relevant).

**Your environment**
python:3.6.0
pydicom:2.1

