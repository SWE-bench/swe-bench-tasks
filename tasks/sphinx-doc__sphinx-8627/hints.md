Unfortunately, the `struct.Struct` class does not have the correct module-info. So it is difficult to support.
```
Python 3.8.2 (default, Mar  2 2020, 00:44:41)
[Clang 11.0.0 (clang-1100.0.33.17)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> import struct
>>> struct.Struct.__module__
'builtins'
```

Note: In python3.9, it returns the correct module-info. But it answers the internal module name: `_struct`.
```
Python 3.9.1 (default, Dec 18 2020, 00:18:40)
[Clang 11.0.3 (clang-1103.0.32.59)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> import struct
>>> struct.Struct.__module__
'_struct'
```

So it would better to use `autodoc_type_aliases` to correct it forcedly.
```
# helloworld.py
from __future__ import annotations  # important!
from struct import Struct

def consume_struct(_: Struct) -> None:
    pass
```
```
# conf.py
autodoc_type_aliases = {
    'Struct': 'struct.Struct',
}
```

Then, it working fine.