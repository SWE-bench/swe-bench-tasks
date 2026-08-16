can open my dicom, error in re.match('^ISO[^_]IR', encoding)
```
(test) root@DESKTOP-COPUCVT:/mnt/e/test# python3 mydicom.py
Traceback (most recent call last):
  File "/root/.local/share/virtualenvs/test-LINKoilU/lib/python3.6/site-packages/pydicom/charset.py", line 625, in convert_encodings
    py_encodings.append(python_encoding[encoding])
KeyError: 73

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "mydicom.py", line 12, in <module>
    pydicom.dcmread("DX.X.1.2.276.0.7230010.3.1.4.313262848.25.1563878256.444385.dcm")
  File "/root/.local/share/virtualenvs/test-LINKoilU/lib/python3.6/site-packages/pydicom/filereader.py", line 850, in dcmread
    force=force, specific_tags=specific_tags)
  File "/root/.local/share/virtualenvs/test-LINKoilU/lib/python3.6/site-packages/pydicom/filereader.py", line 728, in read_partial
    specific_tags=specific_tags)
  File "/root/.local/share/virtualenvs/test-LINKoilU/lib/python3.6/site-packages/pydicom/filereader.py", line 382, in read_dataset
    encoding = convert_encodings(char_set)
  File "/root/.local/share/virtualenvs/test-LINKoilU/lib/python3.6/site-packages/pydicom/charset.py", line 628, in convert_encodings
    _python_encoding_for_corrected_encoding(encoding))
  File "/root/.local/share/virtualenvs/test-LINKoilU/lib/python3.6/site-packages/pydicom/charset.py", line 647, in _python_encoding_for_corrected_encoding
    if re.match('^ISO[^_]IR', encoding) is not None:
  File "/root/.local/share/virtualenvs/test-LINKoilU/lib/python3.6/re.py", line 172, in match
    return _compile(pattern, flags).match(string)
TypeError: expected string or bytes-like object
```

#### Description
 I dont know why pydicom cant open my pictures, but other python library can read the picture and read some meta data correctly. I suspect " if re.match('^ISO[^_]IR', encoding) is not None:"  the encoding here is not string for my dicom picture.   I am new to pydicom, 
Has anyone encountered a similar problem? how to solve it?  need help,thanks!

here is some dicom tags:
![image](https://user-images.githubusercontent.com/32253100/61868213-8016f500-af0b-11e9-8736-8703230229cf.png)
![image](https://user-images.githubusercontent.com/32253100/61868247-91600180-af0b-11e9-8767-a4045e901b8f.png)
![image](https://user-images.githubusercontent.com/32253100/61868284-a50b6800-af0b-11e9-88fd-10180e0acf56.png)



#### Steps/Code to Reproduce
```py

import pydicom
import os
import numpy
child_path = "DX.X.1.2.276.0.7230010.3.1.4.313262848.25.1563878256.444385.dcm"
pydicom.dcmread("DX.X.1.2.276.0.7230010.3.1.4.313262848.25.1563878256.444385.dcm"）

```

#### Expected Results
Example: read the file without error

#### Actual Results
cant read the file

#### Versions
v1.3.0

python v3.6

<!-- Thanks for contributing! -->

