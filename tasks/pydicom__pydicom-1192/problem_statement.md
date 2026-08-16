"TypeError: 'NoneType' object is not subscriptable" when reading dcm file with empty string as Chartset and "use_none_as_empty_text_VR_value=True"
**Describe the bug**
Once thing I noticed is that `convert_encodings` in `charset.py` expects a list of encodings (according to the docstrings) from tag `0008,0005` but it can be just a value. 

The problem is when reading Dicom files in production environments I noticed that some devices that are capturing the DICOMs are not very DICOM Compliant and is sending empty string , which it should be allowed as `0008,0005` is a 1C type, which means that if present it should have a valid value. 

I enabled `use_none_as_empty_text_VR_value` to make sure other tags whose value should be float or int have None instead of empty string, but if `0008,0005` value is empty string is switched to None and `convert_encodings` fails with `TypeError: 'NoneType' object is not subscriptable`

**Expected behavior**
The expected behavior should be that if empty string or not present it should default to:
```
# default encoding if no encoding defined - corresponds to ISO IR 6 / ASCII
default_encoding = "iso8859"
```

**Steps To Reproduce**

out.dcm file if provided for testing with mock data but `Specific Character Set` set to empty string

If setting the `(0008, 0005) Specific Character Set` to empty string and setting `pydicom.config.use_none_as_empty_text_VR_value = True`

```
>>> import pydicom
>>> pydicom.config.datetime_conversion = True
>>> pydicom.config.allow_DS_float = True
>>> pydicom.config.use_none_as_empty_text_VR_value = True
>>> dataset = pydicom.dcmread("test.dcm")
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/Users/bernardo/.virtualenvs/backend-api/lib/python3.7/site-packages/pydicom/filereader.py", line 871, in dcmread
    force=force, specific_tags=specific_tags)
  File "/Users/bernardo/.virtualenvs/backend-api/lib/python3.7/site-packages/pydicom/filereader.py", line 744, in read_partial
    specific_tags=specific_tags)
  File "/Users/bernardo/.virtualenvs/backend-api/lib/python3.7/site-packages/pydicom/filereader.py", line 383, in read_dataset
    encoding = convert_encodings(char_set)
  File "/Users/bernardo/.virtualenvs/backend-api/lib/python3.7/site-packages/pydicom/charset.py", line 638, in convert_encodings
    encodings = encodings[:]
TypeError: 'NoneType' object is not subscriptable
>>> pydicom.config.use_none_as_empty_text_VR_value = False
>>> dataset = pydicom.dcmread("test.dcm")
```
`(0008, 0005) Specific Character Set              CS: ''`

**Your environment**

```bash
python -m pydicom.env_info
module       | version
------       | -------
platform     | Darwin-19.6.0-x86_64-i386-64bit
Python       | 3.7.6 (default, Dec 30 2019, 19:38:26)  [Clang 11.0.0 (clang-1100.0.33.16)]
pydicom      | 2.0.0
gdcm         | _module not found_
jpeg_ls      | _module not found_
numpy        | _module not found_
PIL          | 7.0.0
```


[out.dcm.zip](https://github.com/pydicom/pydicom/files/5248618/out.dcm.zip)

