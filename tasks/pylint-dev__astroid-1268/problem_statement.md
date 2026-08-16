'AsStringVisitor' object has no attribute 'visit_unknown'
```python
>>> import astroid
>>> astroid.nodes.Unknown().as_string()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/Users/tusharsadhwani/code/marvin-python/venv/lib/python3.9/site-packages/astroid/nodes/node_ng.py", line 609, in as_string
    return AsStringVisitor()(self)
  File "/Users/tusharsadhwani/code/marvin-python/venv/lib/python3.9/site-packages/astroid/nodes/as_string.py", line 56, in __call__
    return node.accept(self).replace(DOC_NEWLINE, "\n")
  File "/Users/tusharsadhwani/code/marvin-python/venv/lib/python3.9/site-packages/astroid/nodes/node_ng.py", line 220, in accept
    func = getattr(visitor, "visit_" + self.__class__.__name__.lower())
AttributeError: 'AsStringVisitor' object has no attribute 'visit_unknown'
>>> 
```
### `python -c "from astroid import __pkginfo__; print(__pkginfo__.version)"` output

2.8.6-dev0
