Yield self is inferred to be of a mistaken type 
### Steps to reproduce

1. Run the following
```
import astroid


print(list(astroid.parse('''
import contextlib

class A:
    @contextlib.contextmanager
    def get(self):
        yield self

class B(A):
    def play():
        pass

with B().get() as b:
    b.play()
''').ilookup('b')))
```

### Current behavior
```Prints [<Instance of .A at 0x...>]```

### Expected behavior
```Prints [<Instance of .B at 0x...>]```


### `python -c "from astroid import __pkginfo__; print(__pkginfo__.version)"` output
2.6.2
