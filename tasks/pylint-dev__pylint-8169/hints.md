Could you upgrade to at least 2.15.10 (better yet 2.16.0b1) and confirm the issue still exists, please ?
Tried with

```
pylint 2.15.10
astroid 2.13.4
Python 3.9.16 (main, Dec  7 2022, 10:16:11)
[Clang 14.0.0 (clang-1400.0.29.202)]
```
and also with pylint 2.16.0b1 and I still get the same issue.
Thank you ! I can reproduce, and ``ignored-modules`` does work with a simpler example like ``random.foo``
@Pierre-Sassoulas is the fix here:
1. figure out why the ccxt library causes a `no-name-in-module` msg
2. figure out why using `ignored-modules` is still raising `no-name-in-module`
?
Yes, I think 2/ is the one to prioritize as it's going to be useful for everyone and not just ccxt users. But if we manage find the root cause of 1/ it's going to be generic too.
There is a non-ccxt root cause. This issue can be reproduced with the following dir structure:

```
pkg_mod_imports/__init__.py
pkg_mod_imports/base/__init__.py
pkg_mod_imports/base/errors.py
```
pkg_mod_imports/__init__.py should have :
```
base = [
    'Exchange',
    'Precise',
    'exchanges',
    'decimal_to_precision',
]
```

and  pkg_mod_imports/base/errors.py

```
class SomeError(Exception):
    pass
```

in a test.py module add
```
from pkg_mod_imports.base.errors import SomeError
```
And then running `pylint test.py` the result is
```
test.py:1:0: E0611: No name 'errors' in module 'list' (no-name-in-module)
```

It's coming from the fact that `errors` is both a list inside the init file and the name of a module. variable.py does `module = next(module.getattr(name)[0].infer())` . `getattr` fetches the `errors` list, not the module!