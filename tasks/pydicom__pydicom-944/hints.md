Well, this is invalid DICOM, so strictly speaking this is not a bug, but we can probably just ignore the null character and change the error into a warning (if `config.enforce_valid_values` is not set).
> Well, this is invalid DICOM, so strictly speaking this is not a bug, but we can probably just ignore the null character and change the error into a warning (if `config.enforce_valid_values` is not set).

We could do that, but given that this is the first time seeing an error like this, I don't think it is worth the effort.  Instead, I think using [data_element_callback](https://pydicom.github.io/pydicom/stable/api_ref.html#pydicom.config.data_element_callback) is better suited - example of how to use in my comment [here](https://github.com/pydicom/pydicom/issues/820#issuecomment-473500989).  Not quite the same situation, but could be adapted to replace the bad value.
I'm in favour of ignoring it with a warning/exception, its not really any different from all the other non-conformant fixes we have.
I guess a terminating null is probably common enough carry-over from C that we could be tolerant to reading that.  I'm worried about chasing invalid DICOM endlessly, though, when there is an existing facility for people to filter any kind of invalid values out, and every extra check hits performance, if only a small amount.  Perhaps we just need to make that `util.fixer` code easier to use, maybe a `pydicom.config` setting to set characters to strip as a one-liner before reading a file.
Yeah, I see your point... the code gets messier each time we add a workaround for another incarnation of invalid DICOM. 
This concrete exception happens during Python encoding lookup (as a fallback to check if the encoding is already a Python encoding), where we only expect a `LookupError`. The actual fix, if we would add one, would have to happen earlier (like stripping any trailing zero byte from string values), but I'm not sure if that's worth it.
It may be interesting to understand where this comes from, as I doubt any major DICOM library or modality would have written such a value, and if this may happen elsewhere. I would also check if dcmtk handles this - if they do, I would be more inclined to add a fix. 
Ok, dcmdump just ignores it (I replaced the last '0' by a a zero):
```(0008,0005) CS [ISO_IR 10 ]                             #  10, 1 SpecificCharacterSet```

> I'm worried about chasing invalid DICOM endlessly, though, when there is an existing facility for people to filter any kind of invalid values out, and every extra check hits performance, if only a small amount.

Fair enough. Perhaps we could update fixer (if needed) and have a 'library' of available fixes instead and make sure its all documented. That way in the future we can just add to the library instead of adding a workaround to the codebase.
I read your answers but cannot adapt the callback to my own situation. I really do not understand how dicom is organized and parsed.  All I want is to grab the pixel array and do something. Would Appreciate if you could update the version and fix it.
As @mrbean-bremen said, this can't currently be fixed using `config.data_element_callback` because that gets called after reading while the exception is raised during reading (because character set is special). We'd need an earlier hook if we want to go the fixer route.
Let's try this again... quick workaround.
```python
import codecs
import re

from pydicom import charset
from pydicom import dcmread

def _python_encoding_for_corrected_encoding(encoding):
    encoding = encoding.strip(' \r\t\n\0')

    # standard encodings
    patched = None
    if re.match('^ISO[^_]IR', encoding) is not None:
        patched = 'ISO_IR' + encoding[6:]
    # encodings with code extensions
    elif re.match('^(?=ISO.2022.IR.)(?!ISO 2022 IR )',
                  encoding) is not None:
        patched = 'ISO 2022 IR ' + encoding[12:]

    if patched:
        # handle encoding patched for common spelling errors
        try:
            py_encoding = python_encoding[patched]
            charset._warn_about_invalid_encoding(encoding, patched)
            return py_encoding
        except KeyError:
            charset._warn_about_invalid_encoding(encoding)
            return default_encoding

    # fallback: assume that it is already a python encoding
    try:
        codecs.lookup(encoding)
        return encoding
    except LookupError:
        charset._warn_about_invalid_encoding(encoding)
        return default_encoding

charset._python_encoding_for_corrected_encoding = _python_encoding_for_corrected_encoding

ds = dcmread(...)
```
Interestingly we actually do handle charset values that have trailing padding `\x00`, through `valuerep.MultiString`, what we don't do is handle values that end in more than one null (i.e. `\x00\x00`) which is the case here.

We could change [this line](https://github.com/pydicom/pydicom/blob/a0300a69a1da1626caef0d9738cff29b17ce79cc/pydicom/valuerep.py#L548)
```python
while val.endswith(' ') or val.endswith('\x00'):
    val = val[:-1]
```
Hm, that looks like an easy fix without impact - I wasn't aware of this. The only question is - should we warn in this case?
That being said, I still think that your proposal to add a repository of available fixes is a good one, even if not applicable to this issue.