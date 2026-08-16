Minimal case:

```python
class Example:
    def func(self):
        pass


whatthe = object()
whatthe.func = None

ex = Example()
ex.func()   # false-positive: not-callable
```
Not caused by 78d5537, just revealed by it. `typing` imported `collections`, `collections.OrderedDict` had an ambiguously inferred case that was previously broken by failure with positional-only arguments which was fixed in 78d5537.