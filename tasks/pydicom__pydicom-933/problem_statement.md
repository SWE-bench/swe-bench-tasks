Deferred Read Fails For File-Like Objects
#### Description
Deferred reads are failing when dcmread is passed a file-like object (instead of a filepath).  There are two old issues from 2014 which describe the same issue which were apparently fixed, but I'm still seeing it on v1.3:
https://github.com/pydicom/pydicom/issues/104
https://github.com/pydicom/pydicom/issues/74

#### Steps/Code to Reproduce
```
import io
import pydicom

with open("./0.dcm", "rb") as fp:
   data = fp.read()
filelike = io.BytesIO(data)

dataset = pydicom.dcmread(filelike, defer_size=1024)
print(len(dataset.PixelData))
```

#### Expected Results
Pydicom should hold onto the supplied file-like and use that for the deferred read, rather than trying to grab the file-like's .name/.filename attr and use that to re-open.  It could also hold onto it's own open'd file-like (if supplied a file_path) and use that for deferred reads to simplify things.

#### Actual Results
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/local/lib/python3.6/dist-packages/pydicom/dataset.py", line 747, in __getattr__
    data_elem = self[tag]
  File "/usr/local/lib/python3.6/dist-packages/pydicom/dataset.py", line 826, in __getitem__
    data_elem)
  File "/usr/local/lib/python3.6/dist-packages/pydicom/filereader.py", line 911, in read_deferred_data_element
    raise IOError("Deferred read -- original filename not stored. "
OSError: Deferred read -- original filename not stored. Cannot re-open

#### Versions
Linux-4.18.0-25-generic-x86_64-with-Ubuntu-18.10-cosmic
Python 3.6.7 (default, Oct 22 2018, 11:32:17) 
pydicom 1.3.0
