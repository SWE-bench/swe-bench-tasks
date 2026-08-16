infer_stmts cannot infer multiple uses of the same AssignName
Given multiple assignments to the same target which both reference the same AssignName, infer_stmts fails for subsequent attempts after the first.

### Steps to reproduce

This appears to be a minimum working example, removing any part removes the effect:

```python
fails = astroid.extract_node("""
    pair = [1, 2]
    ex = pair[0]
    if 1 + 1 == 2:
        ex = pair[1]
    ex
""")
print(list(fails.infer()))
# [<Const.int l.2 at 0x...>, Uninferable]
```

For some context, I originally saw this with attributes on an imported module, i.e.

```python
import mod
ex = mod.One()
# later ... or in some branch
ex = mod.Two()
```

### Current behavior

See above.

### Expected behavior

Inlining the variable or switching to a different name works fine:

```python
works = astroid.extract_node("""
    # pair = [1, 2]
    ex = [1, 2][0]
    if 1 + 1 == 2:
        ex = [1, 2][1]
    ex
""")
print(list(works.infer()))
# [<Const.int l.3 at 0x...>, <Const.int l.5 at 0x...>]

works = astroid.extract_node("""
    first = [1, 2]
    second = [1, 2]
    ex = first[0]
    if 1 + 1 == 2:
        ex = second[1]
    ex
""")
print(list(works.infer()))
# [<Const.int l.2 at 0x...>, <Const.int l.3 at 0x...>]
```

I would expect that the first failing example would work similarly. This (only) worked
in astroid 2.5 and appears to have been "broken" by the revert of cc3bfc5 in 03d15b0 (astroid 2.5.1 and above).

### ``python -c "from astroid import __pkginfo__; print(__pkginfo__.version)"`` output

```
$ python -c "from astroid import __pkginfo__; print(__pkginfo__.version)"
2.5-dev
$ git rev-parse HEAD
03d15b0f32f7d7c9b2cb062b9321e531bd954344
```

