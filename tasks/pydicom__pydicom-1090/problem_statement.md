Write deflated content when called Transfer Syntax is Deflated Explicit VR Little Endian
**Describe the bug**
After using `dcmread` to read a deflated .dcm file created from pydicom's [CT_small.dcm sample](https://github.com/pydicom/pydicom/blob/v1.4.2/pydicom/data/test_files/CT_small.dcm), with the following file meta information
```
(0002, 0000) File Meta Information Group Length  UL: 178
(0002, 0001) File Meta Information Version       OB: b'\x00\x01'
(0002, 0002) Media Storage SOP Class UID         UI: CT Image Storage
(0002, 0003) Media Storage SOP Instance UID      UI: 1.3.6.1.4.1.5962.1.1.1.1.1.20040119072730.12322
(0002, 0010) Transfer Syntax UID                 UI: Deflated Explicit VR Little Endian
(0002, 0012) Implementation Class UID            UI: 1.2.40.0.13.1.1
(0002, 0013) Implementation Version Name         SH: 'dcm4che-2.0'
```

I use `save_as` to save the file. The output file has an unaltered file meta information section, but the group 8 elements and beyond are not written in deflated format, instead appearing to be LEE. In particular, the specific character set element is easily readable from a hex representation of the file, rather than appearing as gobbledygook like one would expect from a deflated stream.

**Expected behavior**
The bulk of the DCM to be written as Deflated Explicit VR Little Endian or the Transfer Syntax UID to be saved with a value that reflects the actual format of the DCM

**Steps To Reproduce**
```python
❯ py
>>> # CT_small_deflated.dcm is CT_small.dcm, deflated using dcm2dcm
>>> ds = pydicom.dcmread("CT_small_deflated.dcm")

>>> ds.save_as("ds_like_orig.dcm", write_like_original=True)
>>> pydicom.dcmread("ds_like_orig.dcm")
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "C:\Users\blairyat\AppData\Local\Programs\Python\Python38-32\lib\site-packages\pydicom\filereader.py", line 869, in dcmread
    dataset = read_partial(fp, stop_when, defer_size=defer_size,
  File "C:\Users\blairyat\AppData\Local\Programs\Python\Python38-32\lib\site-packages\pydicom\filereader.py", line 729, in read_partial
    unzipped = zlib.decompress(zipped, -zlib.MAX_WBITS)
zlib.error: Error -3 while decompressing data: invalid stored block lengths

>>> ds.save_as("ds_not_like_orig.dcm", write_like_original=False)
>>> pydicom.dcmread("ds_not_like_orig.dcm")
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "C:\Users\blairyat\AppData\Local\Programs\Python\Python38-32\lib\site-packages\pydicom\filereader.py", line 869, in dcmread
    dataset = read_partial(fp, stop_when, defer_size=defer_size,
  File "C:\Users\blairyat\AppData\Local\Programs\Python\Python38-32\lib\site-packages\pydicom\filereader.py", line 729, in read_partial
    unzipped = zlib.decompress(zipped, -zlib.MAX_WBITS)
zlib.error: Error -3 while decompressing data: invalid stored block lengths
```

**Your environment**
Please run the following and paste the output.
```powershell
❯ py -c "import platform; print(platform.platform())"
Windows-10-10.0.18362-SP0

❯ py -c "import sys; print('Python ', sys.version)"
Python  3.8.1 (tags/v3.8.1:1b293b6, Dec 18 2019, 22:39:24) [MSC v.1916 32 bit (Intel)]

❯ py -c "import pydicom; print('pydicom ', pydicom.__version__)"
pydicom  1.4.2
```

