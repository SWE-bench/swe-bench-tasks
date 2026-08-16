"Printing" of certain dicom files fails once, but works the second time
<!-- Instructions For Filing a Bug: https://github.com/pydicom/pydicom/blob/master/CONTRIBUTING.md#filing-bugs -->

#### Description
"Printing" of certain dicom files (see [example](https://github.com/pydicom/pydicom/files/2865551/dicom_exception.zip)) fails once, but not the second time

#### Steps/Code to Reproduce
```python
from pydicom import read_file

a = read_file('...')
print(a)
# triggers exception: AttributeError: With tag (0028, 3000) got exception: Failed to resolve ambiguous VR for tag (0028, 3002): 'Dataset' object has no attribute 'PixelRepresentation'

# try same thing again...
print(a)
# just works...
```

#### Versions
Behaviour as described above at least on:
```
Linux-4.18.0-15-generic-x86_64-with-Ubuntu-18.10-cosmic
('Python', '2.7.15+ (default, Oct  2 2018, 22:12:08) \n[GCC 8.2.0]')
('numpy', '1.14.5')
('pydicom', '1.3.0.dev0')
```
and


```
('pydicom', '1.2.2')
```

Works as expected on:
```
Linux-4.18.0-15-generic-x86_64-with-Ubuntu-18.10-cosmic
('Python', '2.7.15+ (default, Oct  2 2018, 22:12:08) \n[GCC 8.2.0]')
('pydicom', '1.0.1')
```
