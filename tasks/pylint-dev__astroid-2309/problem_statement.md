Regression in Astroid version 2.15.7 in handling subscriptable type parameters
Astroid version 2.15.7 fails to correctly handle a subscriptable type parameter  most likely due to the change in this [PR](https://github.com/pylint-dev/astroid/pull/2239). 

### Steps to reproduce

```python
from collections.abc import Mapping
from typing import Generic, TypeVar, TypedDict
from dataclasses import dataclass

class Identity(TypedDict):
    """It's the identity."""

    name: str

T = TypeVar("T", bound=Mapping)

@dataclass
class Animal(Generic[T]):
    """It's an animal."""

    identity: T

class Dog(Animal[Identity]):
    """It's a Dog."""

dog = Dog(identity=Identity(name="Dog"))
print(dog.identity["name"])
```

### Current behavior
Pylint (running Astroid 2.15.7) gives the following error for the example above:
```
E1136: Value 'dog.identity' is unsubscriptable (unsubscriptable-object)
```
### Expected behavior
Astroid should correctly handle a subscriptable type parameter.


### `python -c "from astroid import __pkginfo__; print(__pkginfo__.version)"` output
2.15.7
