Revise the type annotation for pydicom.datadict.dictionary_has_tag()
**Describe the bug**

The documentation of [`pydicom.datadict.dictionary_has_tag()`](https://pydicom.github.io/pydicom/dev/reference/generated/pydicom.datadict.dictionary_has_tag.html#pydicom.datadict.dictionary_has_tag) suggests that a query using keywords (instead of a tag integer) would work:

```python
pydicom.datadict.dictionary_has_tag(tag: Union[int, str, Tuple[int, int], pydicom.tag.BaseTag]) -> bool
```

However, the function only accepts integer arguments.

```python
from pydicom.datadict import dictionary_has_tag, keyword_dict
dictionary_has_tag("PixelData")
# Returns False

dictionary_has_tag(keyword_dict["PixelData"])
# Returns True
```

(The problem may apply to other functions as well...)

**Expected behavior**
Following the docs, `dictionary_has_tag("PixelData")` should return True. 

It would be nice, if the flexible conversion of tags from names or hex-tuples (as the type annotation suggests) would also be possible for this function.

**Your environment**
```text
module       | version
------       | -------
platform     | macOS-10.14.6-x86_64-i386-64bit
Python       | 3.9.0 (v3.9.0:9cf6752276, Oct  5 2020, 11:29:23)  [Clang 6.0 (clang-600.0.57)]
pydicom      | 2.2.2
gdcm         | _module not found_
jpeg_ls      | _module not found_
numpy        | 1.20.1
PIL          | 8.0.1
pylibjpeg    | _module not found_
openjpeg     | _module not found_
libjpeg      | _module not found_
```


