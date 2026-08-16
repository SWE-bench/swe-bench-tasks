@property members defined in metaclasses of a base class are not correctly inferred
Ref https://github.com/PyCQA/astroid/issues/927#issuecomment-817244963

Inference works on the parent class but not the child in the following example:

```python
class BaseMeta(type):
    @property
    def __members__(cls):
        return ['a', 'property']
class Parent(metaclass=BaseMeta):
    pass
class Derived(Parent):
    pass
Parent.__members__  # [<Set.set l.10 at 0x...>]
Derived.__members__  # [<Property.__members__ l.8 at 0x...>]
```
