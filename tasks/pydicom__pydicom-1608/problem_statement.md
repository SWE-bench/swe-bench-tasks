Unable to assign single element list to PN field
I am getting `AttributeError` while trying to assign a list of single element to a `PN` field.
It's converting `val` to a 2D array [here](https://github.com/pydicom/pydicom/blob/master/pydicom/filewriter.py#L328) when `VM` is 1. 

**Code**
```
>>> from pydicom import dcmread, dcmwrite
>>> ds = dcmread("SOP1.dcm")
>>> a = ["name1"]
>>> b = ["name1", "name2"]
>>> ds.PatientName = a
>>> dcmwrite("out.dcm", ds)     # throws the error below
>>> ds.PatientName = b
>>> dcmwrite("out.dcm", ds)     # works fine
```

**Error**
```
Traceback (most recent call last):
  File "/Users/neonbulb/virtualenv/deid/lib/python3.8/site-packages/pydicom/tag.py", line 28, in tag_in_exception
    yield
  File "/Users/neonbulb/virtualenv/deid/lib/python3.8/site-packages/pydicom/filewriter.py", line 662, in write_dataset
    write_data_element(fp, dataset.get_item(tag), dataset_encoding)
  File "/Users/neonbulb/virtualenv/deid/lib/python3.8/site-packages/pydicom/filewriter.py", line 562, in write_data_element
    fn(buffer, elem, encodings=encodings)  # type: ignore[operator]
  File "/Users/neonbulb/virtualenv/deid/lib/python3.8/site-packages/pydicom/filewriter.py", line 333, in write_PN
    enc = b'\\'.join([elem.encode(encodings) for elem in val])
  File "/Users/neonbulb/virtualenv/deid/lib/python3.8/site-packages/pydicom/filewriter.py", line 333, in <listcomp>
    enc = b'\\'.join([elem.encode(encodings) for elem in val])
AttributeError: 'MultiValue' object has no attribute 'encode'

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/Users/neonbulb/virtualenv/deid/lib/python3.8/site-packages/pydicom/filewriter.py", line 1153, in dcmwrite
    _write_dataset(fp, dataset, write_like_original)
  File "/Users/neonbulb/virtualenv/deid/lib/python3.8/site-packages/pydicom/filewriter.py", line 889, in _write_dataset
    write_dataset(fp, get_item(dataset, slice(0x00010000, None)))
  File "/Users/neonbulb/virtualenv/deid/lib/python3.8/site-packages/pydicom/filewriter.py", line 662, in write_dataset
    write_data_element(fp, dataset.get_item(tag), dataset_encoding)
  File "/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/3.8/lib/python3.8/contextlib.py", line 131, in __exit__
    self.gen.throw(type, value, traceback)
  File "/Users/neonbulb/virtualenv/deid/lib/python3.8/site-packages/pydicom/tag.py", line 32, in tag_in_exception
    raise type(exc)(msg) from exc
AttributeError: With tag (0010, 0010) got exception: 'MultiValue' object has no attribute 'encode'
Traceback (most recent call last):
  File "/Users/neonbulb/virtualenv/deid/lib/python3.8/site-packages/pydicom/tag.py", line 28, in tag_in_exception
    yield
  File "/Users/neonbulb/virtualenv/deid/lib/python3.8/site-packages/pydicom/filewriter.py", line 662, in write_dataset
    write_data_element(fp, dataset.get_item(tag), dataset_encoding)
  File "/Users/neonbulb/virtualenv/deid/lib/python3.8/site-packages/pydicom/filewriter.py", line 562, in write_data_element
    fn(buffer, elem, encodings=encodings)  # type: ignore[operator]
  File "/Users/neonbulb/virtualenv/deid/lib/python3.8/site-packages/pydicom/filewriter.py", line 333, in write_PN
    enc = b'\\'.join([elem.encode(encodings) for elem in val])
  File "/Users/neonbulb/virtualenv/deid/lib/python3.8/site-packages/pydicom/filewriter.py", line 333, in <listcomp>
    enc = b'\\'.join([elem.encode(encodings) for elem in val])
AttributeError: 'MultiValue' object has no attribute 'encode'
```
