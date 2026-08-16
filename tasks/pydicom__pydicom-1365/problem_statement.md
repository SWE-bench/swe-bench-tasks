DA class is inconsistent
**Describe the bug**
pydicom.valuerep.DA accepts strings or datetime.date objects - but DA objects created with datetime.date inputs are invalid. 

**Expected behavior**
I would expect both of these expressions to generate the same output:
```
print(f'DA("20201117") => {DA("20201117")}')
print(f'DA(date(2020, 11, 17)) => {DA(date(2020, 11, 17))}')
```
but instead I get
```
DA("20201117") => 20201117
DA(date(2020, 11, 17)) => 2020-11-17
```
The hyphens inserted into the output are not valid DICOM - see the DA description in [Table 6.2-1](http://dicom.nema.org/dicom/2013/output/chtml/part05/sect_6.2.html)

**Steps To Reproduce**
Run the following commands:
```
from pydicom.valuerep import DA
from pydicom.dataset import Dataset
from datetime import date, datetime

print(f'DA("20201117") => {DA("20201117")}')
print(f'DA(date(2020, 11, 17)) => {DA(date(2020, 11, 17))}')

# 1. JSON serialization with formatted string works
ds = Dataset()
ds.ContentDate = '20201117'
json_output = ds.to_json()
print(f'json_output works = {json_output}')

# 2. JSON serialization with date object input is invalid.
ds = Dataset()
ds.ContentDate = str(DA(date(2020, 11, 17)))
json_output = ds.to_json()
print(f'json_output with str(DA..) - invalid DICOM {json_output}')

# 3. JSON serialization with date object fails
ds = Dataset()
ds.ContentDate = DA(date(2020, 11, 17))

# Exception on this line: TypeError: Object of type DA is not JSON serializable
json_output = ds.to_json()

```

I believe that all three approaches should work - but only the first is valid. The method signature on DA's `__new__` method accepts datetime.date objects. 

**Your environment**
```
module       | version
------       | -------
platform     | macOS-10.15.7-x86_64-i386-64bit
Python       | 3.8.6 (default, Oct  8 2020, 14:06:32)  [Clang 12.0.0 (clang-1200.0.32.2)]
pydicom      | 2.1.0
gdcm         | _module not found_
jpeg_ls      | _module not found_
numpy        | 1.19.4
PIL          | 8.0.1
```


