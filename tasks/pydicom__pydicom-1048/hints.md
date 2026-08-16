Good point. We could use `os.fspath`, but that is only available from Python 3.6 onwards, so we probably have to add a respective check...
The `save_as()` method of `Dataset` has the same issue.
Yes, I noticed. I'm on it.
Yep.  I actually started writing code for it at one point, but got side-tracked with other issues.  Basically just wrapping the argument in str() fixes it.
