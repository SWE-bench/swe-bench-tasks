0 byte file causes traceback on dcmreader
<!-- Instructions For Filing a Bug: https://github.com/pydicom/pydicom/blob/master/CONTRIBUTING.md#filing-bugs -->

#### Description
Trying to open a 0 byte file with dcmreader causes a traceback originating in the read_partial method. The problem is line 692 in filereader.py (GitHub):
`    fileobj.seek(-1, 1)`
Changing this to:
`    if peek != b'':
        fileobj.seek(-1, 1)`
Appears to solve the problem, but I don't have the experience to test thoroughly.

#### Steps/Code to Reproduce
Create a 0 byte file
$ touch mysillyfile.dcm
Start python, import pydicom and read the the file
$ python3
Python 3.6.8 (default, Jan  3 2019, 16:11:14) 
[GCC 8.2.1 20181215 (Red Hat 8.2.1-6)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import pydicom
>>> image = pydicom.dcmread('mysillyfile.dcm',force=True)

#### Expected Results
Should either warn that the file is not DICOM or exit gracefully

#### Actual Results
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/local/lib/python3.6/site-packages/pydicom/filereader.py", line 880, in dcmread
    force=force, specific_tags=specific_tags)
  File "/usr/local/lib/python3.6/site-packages/pydicom/filereader.py", line 693, in read_partial
    fileobj.seek(-1, 1)
OSError: [Errno 22] Invalid argument

#### Versions
>>> import platform; print(platform.platform())
Linux-4.19.16-200.fc28.x86_64-x86_64-with-fedora-28-Twenty_Eight
>>> import sys; print("Python", sys.version)
Python 3.6.8 (default, Jan  3 2019, 16:11:14) 
[GCC 8.2.1 20181215 (Red Hat 8.2.1-6)]
>>> import numpy; print("numpy", numpy.__version__)
numpy 1.16.1
>>> import pydicom; print("pydicom", pydicom.__version__)
pydicom 1.2.2
>>> 

Regards
Alan

<!-- Thanks for contributing! -->

