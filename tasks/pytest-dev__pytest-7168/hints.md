This only happens when both `__repr__` and `__getattribute__` are broken, which is a very odd scenario.
```
class SomeClass:
    def __getattribute__(self, attr):
        raise Exception()

    def bad_method(self):
        raise Exception()

def test():
    SomeClass().bad_method()

```

```
============================================================================================== test session starts ===============================================================================================
platform linux -- Python 3.7.7, pytest-5.4.1.dev154+gbe6849644, py-1.8.1, pluggy-0.13.1
rootdir: /home/k/pytest, inifile: tox.ini
plugins: asyncio-0.11.0, hypothesis-5.10.4
collected 1 item                                                                                                                                                                                                 

test_internal.py F                                                                                                                                                                                         [100%]

==================================================================================================== FAILURES ====================================================================================================
______________________________________________________________________________________________________ test ______________________________________________________________________________________________________

    def test():
>       SomeClass().bad_method()

test_internal.py:12: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <test_internal.SomeClass object at 0x7fa550a8f6d0>, attr = 'bad_method'

    def __getattribute__(self, attr):
>       raise Exception()
E       Exception

test_internal.py:6: Exception
============================================================================================ short test summary info =============================================================================================
FAILED test_internal.py::test - Exception
=============================================================================================== 1 failed in 0.07s ================================================================================================
```

```
class SomeClass:
    def __repr__(self):
        raise Exception()

    def bad_method(self):
        raise Exception()

def test():
    SomeClass().bad_method()

```


```
============================================================================================== test session starts ===============================================================================================
platform linux -- Python 3.7.7, pytest-5.4.1.dev154+gbe6849644, py-1.8.1, pluggy-0.13.1
rootdir: /home/k/pytest, inifile: tox.ini
plugins: asyncio-0.11.0, hypothesis-5.10.4
collected 1 item                                                                                                                                                                                                 

test_internal.py F                                                                                                                                                                                         [100%]

==================================================================================================== FAILURES ====================================================================================================
______________________________________________________________________________________________________ test ______________________________________________________________________________________________________

    def test():
>       SomeClass().bad_method()

test_internal.py:9: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <[Exception() raised in repr()] SomeClass object at 0x7f0fd38ac910>

    def bad_method(self):
>       raise Exception()
E       Exception

test_internal.py:6: Exception
============================================================================================ short test summary info =============================================================================================
FAILED test_internal.py::test - Exception
=============================================================================================== 1 failed in 0.07s ================================================================================================
```
> This only happens when both `__repr__` and `__getattribute__` are broken, which is a very odd scenario.

Indeed, I admit that's a very odd scenario (I've faced it when working on some black magic mocking stuff). However, I've opened this issue because I haven't dived into pytest code and maybe it will be understood better by someone who could see in it a more important underlying issue.
The problem is most likely here:

```
INTERNALERROR>   File "/usr/local/lib/python3.8/site-packages/_pytest/_io/saferepr.py", line 23, in _format_repr_exception
INTERNALERROR>     exc_info, obj.__class__.__name__, id(obj)
```

specifically, `obj.__class__` raises, but this isn't expected or handled by `saferepr`. Changing this to `type(obj).__name__` should work.