It appears that this is caused by `InferenceContext` maintaining a strong reference to the mutable set that is shared between clones, see this simplified example:

```python
class Context:
    def __init__(self, path=None):
        self.path = path or set()
    def clone(self):
        return Context(path=self.path)

a = Context()
a.path.add('hello')
b = a.clone()
b.path.add('world')
print(a.path, b.path)
# (set(['world', 'hello']), set(['world', 'hello']))
print(a.path is b.path)
# True
```