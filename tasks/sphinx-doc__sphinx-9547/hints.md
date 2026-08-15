One related problem might be something like:

```
.. c:function:: unsigned HOST_WIDE_INT foo ()
```

Where we have defined `HOST_WIDE_INT` with a typedef to something like `unsigned long`. Can one handle it with Sphinx somehow?
@jakobandersen 