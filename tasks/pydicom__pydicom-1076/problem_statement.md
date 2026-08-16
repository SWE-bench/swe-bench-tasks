Error writing values with VR OF
[Related to this comment](https://github.com/pydicom/pydicom/issues/452#issuecomment-614038937) (I think)

```python
from pydicom.dataset import Dataset
ds = Dataset()
ds.is_little_endian = True
ds.is_implicit_VR = True
ds.FloatPixelData = b'\x00\x00\x00\x00'
ds.save_as('out.dcm')
```
```
Traceback (most recent call last):
  File ".../pydicom/filewriter.py", line 228, in write_numbers
    value.append  # works only if list, not if string or number
AttributeError: 'bytes' object has no attribute 'append'

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File ".../pydicom/filewriter.py", line 230, in write_numbers
    fp.write(pack(format_string, value))
struct.error: required argument is not a float

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File ".../pydicom/tag.py", line 27, in tag_in_exception
    yield
  File ".../pydicom/filewriter.py", line 543, in write_dataset
    write_data_element(fp, dataset.get_item(tag), dataset_encoding)
  File ".../pydicom/filewriter.py", line 472, in write_data_element
    writer_function(buffer, data_element, writer_param)
  File ".../pydicom/filewriter.py", line 236, in write_numbers
    "{0}\nfor data_element:\n{1}".format(str(e), str(data_element)))
OSError: required argument is not a float
for data_element:
(7fe0, 0008) Float Pixel Data                    OF: b'\x00\x00\x00\x00'

[skip]
```
[Error in filewriter](https://github.com/pydicom/pydicom/blob/master/pydicom/filewriter.py#L1007) using `write_numbers` instead of `write_OBvalue`/`write_OWvalue`. Looks like it's been wrong [since 2008](https://github.com/pydicom/pydicom/commit/5d3ea61ffe6877ae79267bf233f258c07c726998). I'm a bit surprised it hasn't come up before.
