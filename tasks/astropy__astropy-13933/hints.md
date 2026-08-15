Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/main/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

GitHub issues in the Astropy repository are used to track bug reports and feature requests; If your issue poses a question about how to use Astropy, please instead raise your question in the [Astropy Discourse user forum](https://community.openastronomy.org/c/astropy/8) and close this issue.

If you feel that this issue has not been responded to in a timely manner, please send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
I can reproduce this also with 5.2.dev . @adrn , I vaguely remember you did some work on pickling such things?
Bit of troubleshooting: if one does `%debug` at that point, then `unit is u.hourangle` will return `False`, and thus one misses the branch that should typeset this: https://github.com/astropy/astropy/blob/0c37a7141c6c21c52ce054f2d895f6f6eacbf24b/astropy/coordinates/angles.py#L315-L329

The easy fix would be to replace `is` with `==`, but in princple I think pickling and unpickling the unit should have ensured the unit remains a singleton.
It seems like currently with pickle we guarantee only `IrreducibleUnits`?
```
In [5]: pickle.loads(pickle.dumps(u.hourangle)) is u.hourangle
Out[5]: False

In [6]: pickle.loads(pickle.dumps(u.rad)) is u.rad
Out[6]: True

In [7]: pickle.loads(pickle.dumps(u.deg)) is u.deg
Out[7]: False
```

EDIT: indeed only `IrreducibleUnits` have an `__reduce__` method that guarantees the units are the same:
https://github.com/astropy/astropy/blob/0c37a7141c6c21c52ce054f2d895f6f6eacbf24b/astropy/units/core.py#L1854-L1864
OK, I think `==` is correct. Will have a fix shortly.