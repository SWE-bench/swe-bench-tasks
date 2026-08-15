SyntaxErrors are thrown before execution, so how would the skip call stop the interpreter from parsing the 'incorrect' syntax?
unless we hook the interpreter that is.
A solution could be to ignore syntax errors based on some parameter
if needed we can extend this to have some functionality to evaluate conditions in which syntax errors should be ignored
please note what i suggest will not fix other compatibility issues, just syntax errors

> SyntaxErrors are thrown before execution, so how would the skip call stop the interpreter from parsing the 'incorrect' syntax?

The Python 3.8 code is included by an import. the idea is that the import should not happen if we are skipping the module.
```python
if sys.version_info < (3, 8):
    skip(msg="Requires Python >= 3.8", allow_module_level=True)

# import must be after the module level skip:
from pos_only import *
```
Hi @omry,

Thanks for raising this.

Definitely we should improve that message. 

> Explain skip with allow_module_level in the error message. this seems in conflict with the spirit of the message.

I'm 👍 on this. 2 is also good, but because `allow_module_level` already exists and is part of the public API, I don't think introducing a new API will really help, better to improve the docs of what we already have.

Perhaps improve the message to something like this:

```
Using pytest.skip outside of a test will skip the entire module, if that's your intention pass `allow_module_level=True`. 
If you want to skip a specific test or entire class, use the @pytest.mark.skip or @pytest.mark.skipif decorators.
```

I think we can drop the `pytestmark` remark from there, it is not skip-specific and passing `allow_module_level` already accomplishes the same.

Thanks @nicoddemus.

> Using pytest.skip outside of a test will skip the entire module, if that's your intention pass `allow_module_level=True`. 
If you want to skip a specific test or entire class, use the @pytest.mark.skip or @pytest.mark.skipif decorators.

This sounds clearer.
Can you give a bit of context of why the message is there in the first place?
It sounds like we should be able to automatically detect if this is skipping a test or skipping the entire module (based on the fact that we can issue the warning).

Maybe this is addressing some past confusion, or we want to push people toward `pytest.mark.skip[if]`, but if we can detect it automatically - we can also deprecate allow_module_level and make `skip()` do the right thing based on the context it's used in.
> Maybe this is addressing some past confusion

That's exactly it, people would use `@pytest.skip` instead of `@pytest.mark.skip` and skip the whole module:

https://github.com/pytest-dev/pytest/issues/2338#issuecomment-290324255

For that reason we don't really want to automatically detect things, but want users to explicitly pass that flag which proves they are not doing it by accident.

Original issue: https://github.com/pytest-dev/pytest/issues/607
Having looked at the links, I think the alternative API to skip a module is more appealing.
Here is a proposed end state:

1. pytest.skip_module is introduced, can be used to skip a module.
2. pytest.skip() is only legal inside of a test. If called outside of a test, an error message is issues.
Example:

> pytest.skip should only be used inside tests. To skip a module use pytest.skip_module. To completely skip a test function or a test class, use the @pytest.mark.skip or @pytest.mark.skipif decorators.

Getting to this end state would include deprecating allow_module_level first, directing people using pytest.skip(allow_module_level=True) to use pytest.skip_module().

I am also fine with just changing the message as you initially proposed but I feel this proposal will result in an healthier state.

-0.5 from my side - I think this is too minor to warrant another deprecation and change.
I agree it would be healthier, but -1 from me for the same reasons as @The-Compiler: we already had a deprecation/change period in order to introduce `allow_module_level`, having yet another one is frustrating/confusing to users, in comparison to the small gains.
Hi, I see that this is still open. If available, I'd like to take this up.