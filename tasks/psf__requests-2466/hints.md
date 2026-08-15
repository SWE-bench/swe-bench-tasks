So it looks like pyinstaller isn't detecting an import of the standard library's `sys` module even though it finds `httplib`, `os` and others. You should see if anyone on [StackOverflow](https://stackoverflow.com) can help you with this (or if this is a bug in pyinstaller). It's certainly not a bug in requests though

So this is sort of a bug with that import machinery and sort of a bug with python 2 and sort of a bug with chardet. On the bright side, there's a fix for it that can be performed in chardet and then vendored into requests, etc. On the not-so-bright side, this _can_ affect urllib3 as well.

I was trying to debug https://github.com/jakubroztocil/httpie/issues/315 with pdb to figure out why I was seeing a different error and ran into an issue with this import logic trying to import `requests.packages.urllib3.pdb` because on Py2, `import pdb` is treated as a implicit relative import first and then a non-relative import second. (Woo, thanks Python 2.) The temporary work-around was to add `from __future__ import absolute_import` to the top of the file I was trying to debug in. This, of course, could be applied to urllib3 and chardet both. I think the better option is to attempt to fix the import machinery stolen wholesale from pip.

@dstufft definitely understands this code better than I do, but as I understand it now: we stop trying to import it at L83 if the `__import__(name)` (which in these cases are `chardet.sys` and `urllib3.pdb`) fails. Instead, I think we need to figure out how to try one last case to actually mimic the regular import machinery. I can imagine more complex import failures, like seeing something like `chardet.os.path` fail, so something like

``` py
import_name = name
while import_name:
    (_, import_name) = import_name.split('.', 1)
    try:
        __import__(import_name)
        module = sys.modules(import_name)
    except ImportError:
        pass

if not module:  # or if module is None:
    raise ImportError(...)

sys.modules[name] = module
return module
```

Does that make sense?
