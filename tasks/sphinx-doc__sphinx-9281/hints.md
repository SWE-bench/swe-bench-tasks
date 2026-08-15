Probably the repr() representation of default arguments is used, and it should be; that is supposed to give a string that, when evaluated, yields the value.

Unfortunately, the enum.Enum implementation in Python does not honor this convention; their repr() includes the Enum value and the "<>" brackets.

In an ideal world we could ask the enum.Enum people to fix that behavior; but I am afraid that would break quite a lot of code in the wild.

The best course of action may be to special-case Enum types in autodoc.
Searched the Python bug-tracker. There is some active discussion going on there to see if/how they should change __repr__ for Enum classes:

https://bugs.python.org/issue40066
A workaround for the issue is to provide a \_\_repr\_\_ emplementation with Enum types, which may be a good idea anyway until the Python folks sort this out:

```
class MyEnum(enum.Enum):
    ValueA = 10
    ValueB = 20

    def __repr__(self):
        return "MyEnum." + self.name
```
