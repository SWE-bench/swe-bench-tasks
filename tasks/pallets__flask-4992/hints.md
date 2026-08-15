You can also use:

```python
app.config.from_file("config.toml", lambda f: tomllib.load(f.buffer))
```
Thanks - I was looking for another way to do it. I'm happy with that for now, although it's worth noting this about `io.TextIOBase.buffer` from the docs:

> This is not part of the [TextIOBase](https://docs.python.org/3/library/io.html#io.TextIOBase) API and may not exist in some implementations.
Oh, didn't mean for you to close this, that was just a shorter workaround. I think a `text=True` parameter would be better, easier to use `True` or `False` rather than mode strings. Some libraries, like `tomllib`, have _Opinions_ about whether text or bytes are correct for parsing files, and we can accommodate that.
can i work on this?
No need to ask to work on an issue. As long as the issue is not assigned to anyone and doesn't have have a linked open PR (both can be seen in the sidebar), anyone is welcome to work on any issue.