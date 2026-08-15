We have a similar problem in the Trio project where we use annotations like "str or list", ThisType or None" or even "bytes-like" in a number of place. Here's an example: https://github.com/python-trio/trio/blob/dependabot/pip/sphinx-3.1.0/trio/_subprocess.py#L75-L96
To clarify a bit on the Trio issue: we don't expect sphinx to magically do anything with `bytes-like`, but currently you can use something like this in a Google-style docstring:

```
    Attributes:
      args (str or list): The ``command`` passed at construction time,
          specifying the process to execute and its arguments.
```

And with previous versions of Sphinx, it renders like this:

![image](https://user-images.githubusercontent.com/609896/84207125-73d55100-aa65-11ea-98e6-4b3b8f619be9.png)

https://trio.readthedocs.io/en/v0.15.1/reference-io.html#trio.Process.args

Notice that `str` and `list` are both hyperlinked appropriately.

So Sphinx used to be able to cope with this kind of "or" syntax, and if it can't anymore it's a regression.
This also occurs with built-in container classes and 'or'-types (in nitpick mode):
```
WARNING: py:class reference target not found: tuple[str]
WARNING: py:class reference target not found: str or None
```

Unfortunately this breaks my CI pipeline at the moment. Does anyone know a work-around other than disabling nitpick mode?
