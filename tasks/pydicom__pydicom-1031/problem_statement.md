Crash writing DICOM with 1.4.0
pydicom 1.4.0
Windows-10-10.0.18362-SP0
Python  3.7.4 (tags/v3.7.4:e09359112e, Jul  8 2019, 20:34:20) [MSC v.1916 64 bit (AMD64)]
GDCM 3.0.2
Pillow 7.0.0

Type error raises when writing file with pydicom 1.4.0, works in 1.3.0.

```
ds = pydicom.read_file('fail2404.anon.dcm')
#print(ds.get((0x0040, 0x0275)))
ds.save_as('bort.dcm')
```

Interestingly, the crash goes away if the offending tag is accessed (uncomment the print and then the `save_as` works fine).

```
Traceback (most recent call last):
  File "C:\Program Files\Python37\lib\site-packages\pydicom\tag.py", line 30, in tag_in_exception
    yield
  File "C:\Program Files\Python37\lib\site-packages\pydicom\filewriter.py", line 555, in write_dataset
    write_data_element(fp, dataset.get_item(tag), dataset_encoding)
  File "C:\Program Files\Python37\lib\site-packages\pydicom\filewriter.py", line 463, in write_data_element
    buffer.write(data_element.value)
TypeError: a bytes-like object is required, not 'list'

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "./pydcmbug.py", line 7, in <module>
    ds.save_as('bort.dcm')
  File "C:\Program Files\Python37\lib\site-packages\pydicom\dataset.py", line 1810, in save_as
    pydicom.dcmwrite(filename, self, write_like_original)
  File "C:\Program Files\Python37\lib\site-packages\pydicom\filewriter.py", line 946, in dcmwrite
    write_dataset(fp, get_item(dataset, slice(0x00010000, None)))
  File "C:\Program Files\Python37\lib\site-packages\pydicom\filewriter.py", line 555, in write_dataset
    write_data_element(fp, dataset.get_item(tag), dataset_encoding)
  File "C:\Program Files\Python37\lib\contextlib.py", line 130, in __exit__
    self.gen.throw(type, value, traceback)
  File "C:\Program Files\Python37\lib\site-packages\pydicom\tag.py", line 37, in tag_in_exception
    raise type(ex)(msg)
TypeError: With tag (0040, 0275) got exception: a bytes-like object is required, not 'list'
Traceback (most recent call last):
  File "C:\Program Files\Python37\lib\site-packages\pydicom\tag.py", line 30, in tag_in_exception
    yield
  File "C:\Program Files\Python37\lib\site-packages\pydicom\filewriter.py", line 555, in write_dataset
    write_data_element(fp, dataset.get_item(tag), dataset_encoding)
  File "C:\Program Files\Python37\lib\site-packages\pydicom\filewriter.py", line 463, in write_data_element
    buffer.write(data_element.value)
TypeError: a bytes-like object is required, not 'list'
```

[fail.zip](https://github.com/pydicom/pydicom/files/4072693/fail.zip)

