Infer calls to str.format() on names
Future enhancement could infer this value instead of giving an empty string:

```python
from astroid import extract_node
call = extract_node("""
x = 'python is {}'
x.format('helpful sometimes')
""")
call.inferred()[0].value  # gives ""
```

_Originally posted by @jacobtylerwalls in https://github.com/PyCQA/astroid/pull/1602#discussion_r893423433_
