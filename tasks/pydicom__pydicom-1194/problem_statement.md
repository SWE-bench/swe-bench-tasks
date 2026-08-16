Error decoding dataset with ambiguous VR element when the value is None
Hi all,
    I used the storescu in pynetdicom 1.5.3 to send the dicom ct files(both on mac and ubuntu): 
**python storescu.py 192.168.1.120 9002 ~/Downloads/test/**
(I also tried https://pydicom.github.io/pynetdicom/stable/examples/storage.html#storage-scu)
but it throwed errors: 

_E: Failed to encode the supplied Dataset
E: Store failed: /Users/me/Downloads/test/CT_S1_118.dcm
E: Failed to encode the supplied Dataset
Traceback (most recent call last):
  File "storescu.py", line 283, in main
    status = assoc.send_c_store(ds, ii)
  File "/Users/me/.pyenv/versions/3.8.2/lib/python3.8/site-packages/pynetdicom/association.py", line 1736, in send_c_store
    raise ValueError('Failed to encode the supplied Dataset')
ValueError: Failed to encode the supplied Dataset_

But I used to send same files with storescu in dcm4che successfully.
File attached.

[test.zip](https://github.com/pydicom/pynetdicom/files/5258867/test.zip)

