Make PersonName3 iterable
```python
from pydicom import Dataset

ds = Dataset()
ds.PatientName = 'SomeName'

'S' in ds.PatientName
```
```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: argument of type 'PersonName3' is not iterable
```

I'm not really sure if this is intentional or if PN elements should support `str` methods. And yes I know I can `str(ds.PatientName)` but it's a bit silly, especially when I keep having to write exceptions to my element iterators just for PN elements.
