Delayed attribute assignment to object() may cause incorrect inference of instance attributes
@cdce8p: `aiohttp` and `VLCTelnet` turned out to be red herrings. This case fails on current stable versions:

```python
class Example:
    def prev(self):
        pass
    def next(self):
        pass
    def other(self):
        pass


ex = Example()
ex.other()  # no warning
ex.prev()   # no warning
ex.next()   # no warning

import typing

ex.other()  # no warning
ex.prev()   # false-positive: not-callable
ex.next()   # false-positive: not-callable
```

_Originally posted by @nelfin in https://github.com/PyCQA/astroid/issues/927#issuecomment-818626368_

I've bisected this down to 78d5537. Pylint 2.3.1 passes this case with 20a7ae5 and fails with 78d5537
