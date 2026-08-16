to_json does not work with binary data in pixel_array
**Describe the issue**
Loading a dicom file and then performing a to_json() on it does not work with binary data in pixel_array.



**Expected behavior**
I would have expected that a base64 conversion is first performed on the binary data and then encoded to json. 

**Steps To Reproduce**
How to reproduce the issue. Please include:
1. A minimum working code sample

import pydicom
ds = pydicom.dcmread('path_to_file')
output = ds.to_json()


2. The traceback (if one occurred)

Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/.virtualenvs/my_env/lib/python3.7/site-packages/pydicom/dataset.py", line 2003, in to_json
    dump_handler=dump_handler
  File "/.virtualenvs/my_env/lib/python3.7/site-packages/pydicom/dataset.py", line 1889, in _data_element_to_json
    binary_value = data_element.value.encode('utf-8')
AttributeError: 'bytes' object has no attribute 'encode'


3. Which of the following packages are available and their versions:
  * Numpy
numpy==1.17.2
  * Pillow
Pillow==6.1.0
  * JPEG-LS
  * GDCM
4. The anonymized DICOM dataset (if possible).

**Your environment**
Please run the following and paste the output.
```bash
$ python -c "import platform; print(platform.platform())"
Darwin-19.2.0-x86_64-i386-64bit
$ python -c "import sys; print('Python ', sys.version)"
Python  3.7.6 (default, Dec 30 2019, 19:38:26) 
[Clang 11.0.0 (clang-1100.0.33.16)]
$ python -c "import pydicom; print('pydicom ', pydicom.__version__)"
pydicom  1.3.0
```

