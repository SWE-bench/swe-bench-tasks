pydicom should not define handler, formatter and log level.
The `config` module (imported when pydicom is imported) defines a handler and set the log level for the pydicom logger. This should not be the case IMO. It should be the responsibility of the client code of pydicom to configure the logging module to its convenience. Otherwise one end up having multiple logs record as soon as pydicom is imported:

Example:
```
Could not import pillow
2018-03-25 15:27:29,744 :: DEBUG :: pydicom 
  Could not import pillow
Could not import jpeg_ls
2018-03-25 15:27:29,745 :: DEBUG :: pydicom 
  Could not import jpeg_ls
Could not import gdcm
2018-03-25 15:27:29,745 :: DEBUG :: pydicom 
  Could not import gdcm
``` 
Or am I missing something?
