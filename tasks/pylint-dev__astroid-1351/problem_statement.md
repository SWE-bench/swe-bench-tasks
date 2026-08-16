Decorator.toline is off by 1
### Steps to reproduce

I came across this inconsistency while debugging why pylint reports `missing-docstring` on the wrong line for the `g2` function in the example. As it turns out, the `toline` of the decorator seems to point to `b=3,` instead of `)`.

```python
import ast
import astroid

source = """\
@f(a=2,
   b=3,
)
def g2():
    pass
"""

[f] = ast.parse(source).body
[deco] = f.decorator_list
print("ast", deco.lineno, deco.end_lineno)

[f] = astroid.parse(source).body
[deco] = f.decorators.nodes
print("astroid", deco.fromlineno, deco.tolineno)
```

### Current behavior

```
ast 1 3
astroid 1 2
```

### Expected behavior

```
ast 1 3
astroid 1 3
```

### `python -c "from astroid import __pkginfo__; print(__pkginfo__.version)"` output

2.9.3
