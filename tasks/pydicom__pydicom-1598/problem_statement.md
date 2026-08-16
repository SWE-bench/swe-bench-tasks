KeyError when saving a FileSet
**Describe the bug**
Saving a fileset that was loaded using DICOMDIR returns a Key Error.

**Expected behavior**
Fileset is saved without error

**Steps To Reproduce**
Code:
```python
from pydicom.fileset import FileSet

fpath="DICOMDIR"
data=FileSet(fpath)

print(data)

data.write(use_existing=True)
```

```
Traceback:
KeyError                                  

Traceback (most recent call last) 
\<ipython-input-183-effc2d1f6bc9\> in \<module\>
      6 print(data)
      7 
----> 8 data.write(use_existing=True)

~/anaconda3/lib/python3.7/site-packages/pydicom/fileset.py in write(self, path, use_existing, force_implicit)
   2146                 self._write_dicomdir(f, force_implicit=force_implicit)
   2147 
-> 2148             self.load(p, raise_orphans=True)
   2149 
   2150             return

~/anaconda3/lib/python3.7/site-packages/pydicom/fileset.py in load(self, ds_or_path, include_orphans, raise_orphans)
   1641             ds = ds_or_path
   1642         else:
-> 1643             ds = dcmread(ds_or_path)
   1644 
   1645         sop_class = ds.file_meta.get("MediaStorageSOPClassUID", None)

~/anaconda3/lib/python3.7/site-packages/pydicom/filereader.py in dcmread(fp, defer_size, stop_before_pixels, force, specific_tags)
   1032             defer_size=size_in_bytes(defer_size),
   1033             force=force,
-> 1034             specific_tags=specific_tags,
   1035         )
   1036     finally:

~/anaconda3/lib/python3.7/site-packages/pydicom/filereader.py in read_partial(fileobj, stop_when, defer_size, force, specific_tags)
    885             file_meta_dataset,
    886             is_implicit_VR,
--> 887             is_little_endian,
    888         )
    889     else:

~/anaconda3/lib/python3.7/site-packages/pydicom/dicomdir.py in __init__(self, filename_or_obj, dataset, preamble, file_meta, is_implicit_VR, is_little_endian)
     94 
     95         self.patient_records: List[Dataset] = []
---> 96         self.parse_records()
     97 
     98     def parse_records(self) -> None:

~/anaconda3/lib/python3.7/site-packages/pydicom/dicomdir.py in parse_records(self)
    143                 )
    144                 if child_offset:
--> 145                     child = map_offset_to_record[child_offset]
    146                     record.children = get_siblings(child, map_offset_to_record)
    147 

KeyError: 572
```

**Your environment**

module       | version
------       | -------
platform     | Linux-4.15.0-142-generic-x86_64-with-debian-stretch-sid
Python       | 3.7.10 (default, Feb 26 2021, 18:47:35)  [GCC 7.3.0]
pydicom      | 2.2.2
gdcm         | _module not found_
jpeg_ls      | _module not found_
numpy        | 1.19.2
PIL          | 8.2.0
pylibjpeg    | _module not found_
openjpeg     | _module not found_
libjpeg      | _module not found_

