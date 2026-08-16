You said on the pynetdicom issue you can't upload an anonymised file, but can you open the file in a hex editor and post the raw byte output from the first few (non-identifying) elements? From the start of the file to the end of say (0008,0070) should be enough.

Alternatively you could truncate the file at the end of the (0008,0070) element and upload that.

If you need to know how to interpret the encoded data check out [Part 5, Chapter 7](http://dicom.nema.org/medical/dicom/current/output/chtml/part05/chapter_7.html) of the DICOM Standard. And if the file's been saved in the [DICOM File Format](http://dicom.nema.org/medical/dicom/current/output/chtml/part10/chapter_7.html) there may also be a 128 byte header  following by 'DICM' before the start of the dataset (which we don't need).
> open the file in a hex editor and post the raw byte output from the first few (non-identifying) elements

Alternatively:
```
import pydicom.config
pydicom.config.debug(True)
ds = dcmread(youfilename)
```
And as suggested copy the first non-identifying part of the debug output for posting.
Please find the truncated dataset attached as requested. I wasn't allowed to upload a *.dcm file so just wrote it as a *.txt file. The file is readable by pydicom but exhibits the same aforementioned problems, where the "LookupError: unknown encoding: Not Supplied" happens only for the Manufacturer tag.

[truncated.txt](https://github.com/pydicom/pydicom/files/2947883/truncated.txt)

Okay, so I've tried deleting SpecificCharacterSet and the error still occurs.  I think pydicom is still holding on to the original values, and needs some code to handle the case when SpecificCharacterSet is deleted or set again after reading the file. We can dig into it a little further.


Workaround:
```python
from pydicom import dcmread

ds = dcmread('path/to/file')
del ds.SpecificCharacterSet
ds.read_encoding = []
```

Brilliant!  That worked! 

Thank you for the quick fix! I've found pydicom is a lot more user-friendly than gdcm so I'm really glad I don't have to resort to that. 😀 
No problem, @mrbean-bremen do you want to handle the underlying issue?
Certainly - as I may have introduced it... Not sure if I'll find the time today though. 