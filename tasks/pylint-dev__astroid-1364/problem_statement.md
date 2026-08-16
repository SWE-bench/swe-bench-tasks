MRO failure on Python 3.7 with typing_extensions
### Steps to reproduce

Run the following script on Python 3.7:

```python
from astroid import parse
module = parse("""
import abc
import typing
import dataclasses

import typing_extensions

T = typing.TypeVar("T")

class MyProtocol(typing_extensions.Protocol): pass
class EarlyBase(typing.Generic[T], MyProtocol): pass
class Base(EarlyBase[T], abc.ABC): pass
class Final(Base[object]): pass
""")

#                    typing.Protocol
#                          |
# typing.Generic[T]    MyProtocol
#              \       /
#              EarlyBase     abc.ABC
#                       \    /
#                        Base
#                         |
#                        Final

final_def = module.body[-1]
final_def.mro()
```

### Current behavior

```
Traceback (most recent call last):
  File "xxx.py", line 31, in <module>
    print("mro:", final_def.mro())
  File "/home/rturner/astroid/astroid/nodes/scoped_nodes.py", line 3009, in mro
    return self._compute_mro(context=context)
  File "/home/rturner/astroid/astroid/nodes/scoped_nodes.py", line 2985, in _compute_mro
    mro = base._compute_mro(context=context)
  File "/home/rturner/astroid/astroid/nodes/scoped_nodes.py", line 2999, in _compute_mro
    return _c3_merge(unmerged_mro, self, context)
  File "/home/rturner/astroid/astroid/nodes/scoped_nodes.py", line 103, in _c3_merge
    context=context,
astroid.exceptions.InconsistentMroError: Cannot create a consistent method resolution order for MROs (tuple, object), (EarlyBase, tuple, Generic, object, MyProtocol), (ABC, object), (tuple, EarlyBase, ABC) of class <ClassDef.Base l.1347 at 0x7fa0efd52590>.
```

### Expected behavior

No MRO error is raised; Python 3.7 doesn't raise an error.

### `python -c "from astroid import __pkginfo__; print(__pkginfo__.version)"` output

2.6.7-dev0; the test case fails in pylint 2.9.6 and on the main branch at commit 6e8699cef0888631bd827b096533fc6e894d2fb2.
