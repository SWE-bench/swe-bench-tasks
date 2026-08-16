Inconsistencies in value testing for PersonName3
```python
from pydicom.dataset import Dataset

ds = Dataset()
ds.PatientName = None  # or ''
if ds.PatientName:
    print('Has a value')
else:
    print('Has no value')

if None:  # or ''
    print('Evaluates as True')
else:
    print('Evaluates as False')
```
Prints `Has a value` then `Evaluates as False`. Should print `Has no value` instead (encoded dataset will have a zero-length element).

Current master, python 3.6.
