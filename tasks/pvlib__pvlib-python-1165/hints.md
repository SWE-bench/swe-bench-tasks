@cwhanse we overlooked updating this in #1129:

https://github.com/pvlib/pvlib-python/blob/b40df75ddbc467a113b87643c1faef073cc37b3e/pvlib/modelchain.py#L1594-L1598

One possible solution is 

```python
if any(p is None for p in poa):
    raise ValueError
```