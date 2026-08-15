Wow! I did not notice the improvement. I'll take a look.
https://docs.python.org/3.9/library/functions.html#classmethod
For anyone wondering, a way to work around this issue currently, that allows usage of attribute docstrings is to refactor

```python
class A:
    @classmethod
    @property
    def fun(cls)
         """docstring"""
        pass
```

into a construct using a metaclass

```python
class MetaClass:
    @property
    def fun(cls):
        """docstring"""

class A(metaclass=MetaClass):
    fun = classmethod(MetaClass.fun)
    """docstring"""
```
