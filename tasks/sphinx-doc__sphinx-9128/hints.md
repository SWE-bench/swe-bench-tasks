I noticed the example is not good. Both `example.StringIO` and `io.StringIO` are aliases of `_io.StringIO`. So they're surely conflicted.

It would be better to not emit a warning for this case:
```
.. autoclass:: _io.StringIO
.. autoclass:: io.StringIO
```

The former one is a canonical name of the `io.StringIO`. So this should not be conflicted.