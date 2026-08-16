Occurs because Pixel Representation is in the top level-dataset while the ambiguous element is in a sequence.

Regression test:
```python
from pydicom.dataset import Dataset

ds = Dataset()
ds.PixelRepresentation = 0
ds.ModalityLUTSequence = [Dataset()]
ds.ModalityLUTSequence[0].LUTDescriptor = [0, 0, 16]
ds.ModalityLUTSequence[0].LUTExplanation = None
ds.ModalityLUTSequence[0].ModalityLUTType = 'US'  # US = unspecified
ds.ModalityLUTSequence[0].LUTData = b'\x0000\x149a\x1f1c\c2637'

ds.is_little_endian= True
ds.is_implicit_VR = False
ds.save_as('test.dcm')
```

The reason it works the second time is the ambiguous VR correction only gets used during the initial decoding (pydicom uses deferred decoding which is triggered by the first `print()`).

This might be a bit tricky to fix elegantly...
One thing we should probably change is to warn rather than raise if ambiguous correction fails during decoding. Should still raise if occurs during encoding
> This might be a bit tricky to fix elegantly...

Yes... we have to support the cases where the tag needed to resolve the ambiguity is in the sequence item, or in any parent dataset (for nested sequences). Having the parent dataset as a member in the dataset would allow this, but this would also mean, that it has always to be set on creating a sequence item... not sure if this is a good idea. 
Another option is to pass the function a dict/Dataset containing elements required for resolving ambiguity (if they're present)