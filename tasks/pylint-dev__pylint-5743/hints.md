The following also crashes without any provided template:
```python
import distutils

import six


def get_unpatched_class(cls):
    ...

def get_unpatched(item):
    lookup = (
        get_unpatched_class if isinstance(item, six.class_types) else
        lambda item: None
    )
    return lookup(item)


_Distribution = get_unpatched(distutils.core.Distribution)

class Distribution(_Distribution):
   
    def patch(cls):
        distutils.core.Distribution = cls
```

This is for `astroid` 2.9.4 and `pylint` on https://github.com/PyCQA/pylint/commit/44ad84a4332dfb89e810106fef2616a0bc7e47e4
@Pierre-Sassoulas Did some investigation and found the issue in 5 minutes. I have a fix, just need to figure out a good test. If you got one as well, please go ahead otherwise you can assign me to this!
You're fast 😄 ⚡ I assigned to myself yesterday but haven't been able to investigate since :)
I had 20 minutes to spare on an airplane without internet and this was the only issue I could reproduce without any further information 😄 
Fix itself is quite easy, but I need to look up method patching with `pytest`. That's something I can't do without internet 😅 