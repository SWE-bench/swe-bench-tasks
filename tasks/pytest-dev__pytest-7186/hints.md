Seems reasonable to me to change this line:

```
/***/lib64/python3.6/site-packages/_pytest/doctest.py:123: in _is_setup_py
    contents = path.read()
```

to `path.read_text(encoding="utf-8")`.

Using the `locale.getpreferredencoding()` for reading Python files is probably wrong -- in Python 3, python files are expected to be UTF-8, unless overridden by a `* coding *` directive. Since we are not going to be sniffing the coding ourselves, and I'm not aware of any function that does it for us, UTF-8 seems like the best assumption. It would be even better to not read the file at all, but I didn't check why we do that.

@arekfu, if you make this change, does everything work, or are there any other failures?

BTW, since Python 3.7, the `C` locale gives UTF-8, not ASCII (see https://www.python.org/dev/peps/pep-0538/). But you are using Python 3.6.
Yes, `read_text()` fixes the exception, provided that I run `pytest` and not `pytest setup.py` as I wrote in the minimal example (but why would you do that?).

Indeed, I noticed that Python 3.8 did not have this problem on another machine.