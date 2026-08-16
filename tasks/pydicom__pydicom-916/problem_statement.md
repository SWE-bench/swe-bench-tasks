To_Json 'str' object has no attribute 'components'
<!-- Instructions For Filing a Bug: https://github.com/pydicom/pydicom/blob/master/CONTRIBUTING.md#filing-bugs -->

#### Description
<!-- Example: Attribute Error thrown when printing (0x0010, 0x0020) patient Id> 0-->

When converting a dataset to json the following error occurs.
```
Traceback (most recent call last):
  File "/anaconda3/lib/python3.6/threading.py", line 916, in _bootstrap_inner
    self.run()
  File "/anaconda3/lib/python3.6/threading.py", line 864, in run
    self._target(*self._args, **self._kwargs)
  File "~/pacs-proxy/pacs/service.py", line 172, in saveFunction
    jsonObj = ds.to_json()
  File "~/lib/python3.6/site-packages/pydicom/dataset.py", line 2046, in to_json
    dump_handler=dump_handler
  File "~/lib/python3.6/site-packages/pydicom/dataelem.py", line 447, in to_json
    if len(elem_value.components) > 2:
AttributeError: 'str' object has no attribute 'components'
```
#### Steps/Code to Reproduce

ds = pydicom.dcmread("testImg")
jsonObj = ds.to_json()

I'm working on getting an anonymous version of the image, will update. But any advice, suggestions would be appreciated.

#### 
