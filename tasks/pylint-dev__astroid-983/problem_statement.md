Cannot infer empty functions
### Steps to reproduce
```python
import astroid
astroid.extract_node("""
def f():
    pass
f()
""").inferred()
```
### Current behavior
raises `StopIteration`

### Expected behavior
Returns `[const.NoneType]`

### ``python -c "from astroid import __pkginfo__; print(__pkginfo__.version)"`` output

2.0.0

This also applies to procedural functions which don't explicitly return any values.
