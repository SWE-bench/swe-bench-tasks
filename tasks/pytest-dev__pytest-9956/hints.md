Hi @maxrothman,

Thanks for the suggestion. I appreciate where you are coming from, but I don't think this is a good idea:

* It is somewhat implicit to me that returning `False` from a test function would cause the test to fail. Also, it would fail with what message? `assert` statements are the bread and butter of tests in pytest after all.
* I've seen many times users using plain `return` to stop a test in the middle of the execution (for example, in a parametrized test one of the parameters only goes through the middle of the test). This would cause those test suites to fail.

So while I see that a few users might get confused by that, I don't think it is common enough to create a special case for it and also possibly breaking backward compatibility, so 👎 from me.

This is also a good opportunity to advocate users to see their tests fail first before fixing code, to ensure they are not testing a false positive.

But again, thanks for the suggestion and taking the time to write about it.
Responses inline:

> * It is somewhat implicit to me that returning `False` from a test function would cause the test to fail. Also, it would fail with what message? `assert` statements are the bread and butter of tests in pytest after all.

I think we agree? I'm not suggesting that returning the result of a test should be made valid, I'm suggesting that returning **at all** from a test function is probably a typo and thus should fail loudly with a message indicating that the user probably made a typo.

> * I've seen many times users using plain `return` to stop a test in the middle of the execution (for example, in a parametrized test one of the parameters only goes through the middle of the test). This would cause those test suites to fail.

From my suggestion (emphasis added):
> I propose that test functions that return **anything except None** fail with a message that cues users that they probably meant to assert rather than return.

Plain returns would be allowed, since a plain return implicitly returns `None`.
 
> So while I see that a few users might get confused by that, I don't think it is common enough to create a special case for it and also possibly breaking backward compatibility, so 👎 from me.

If backward-compatibility is an issue (which I suspect it wouldn't be, since no one should be returning anything but None from tests) this feature could be downgraded to a warning (or upgraded from a warning to an error) by a config flag.

> But again, thanks for the suggestion and taking the time to write about it.

Thank you for quickly responding! I hope my comment cleared up some confusion and that you'll reconsider your 👎. In either case, thank you for helping to maintain pytest!
Indeed, my mistake, thanks for clarifying. 

I'm still not convinced that this is common enough to warrant an error/warning however, but I'm changing my vote to -0.5 now that the proposal is clearer to me.

If others provide more use cases or situations where this error is common then I'm not against adding a warning for tests which return non-None. 😁 
(I've changed the title of the issue to better describe the proposal, feel free to edit it further or revert it in case you disagree)
I'm +1 on this - in fact Hypothesis already makes non-`None` returns from wrapped tests into errors.

- it catches some trivial user errors, as noted in the OP
- more importantly, it also catches problems like definining generators as tests (or async test functions), where calling the function doesn't actually execute the test body.  On this basis we could e.g. explicitly recommend `pytest-asyncio` or `pytest-trio` if an awaitable object is returned.

I'd probably do this as a warning to start with, have an option to disable the warning, and then upgrade it to an error (still disabled by the same option) in pytest 6.0
Thanks @Zac-HD for the feedback. 👍 

> I'd probably do this as a warning to start with, have an option to disable the warning, and then upgrade it to an error (still disabled by the same option) in pytest 6.0

Probably a bit late for 6.0, given that 5.5 won't happen so users wouldn't have a chance to see the warning.

Didn't realise it was that soon! Warning in 6.0 then, and error in 7.0 I guess :slightly_smiling_face: 
I'm a little hesitant about this one, I've seen a few testsuites where there's like

```python
def test_one():
    # do some stuff
    # assert some stuff
    return some_info()

def test_two():
    res = test_one()
    # do more things
    # assert more things
```

I'm not saying they're good tests, but forbidding return will break them (the test works fine and returning *something* isn't breaking its correctness)
(though, I do think this will be less painful than the don't-call-fixtures change)
I am guilty of such testsuites myself and I think it's warranted to extract operational components to function 
> I am guilty of such testsuites myself and I think it's warranted to extract operational components to function

I extract common components into tests all the time, but I’d argue that the better design would be to have both tests call a shared function, rather than piggyback one test off of another, and that pytest should encourage better design. In any case, do you think such usage is common? If not, does the config flag address this concern? 
my note is about refactoring to common functions instead of running other test functions
I think the option given by @Zac-HD sounds like a good path forward 
+1 from me, I cannot think of much use in returning from a test in what I would deem 'good practice'.
there is one specialc ase - whch is pytest-twisted and deferreds
> there is one specialc ase - whch is pytest-twisted and deferreds

Indeed, but if I understand correctly, those tests are marked in a way that plugins will use `pytest_pyfunc_call` to intercept them and do something special with the return value.

The proposal seem to apply only for "normal" test functions, handled by pytest itself. Correct?
Same for `pytest-asyncio` and `pytest-trio`, if I remember correctly.  So we should confirm that 

- our new check for non-`None` return is 'outside' the plugin layer that handles async tests
- the various plugins `pytest-{asyncio,trio,twisted}` either contain an equivalent check or pass through the return value
> > there is one specialc ase - whch is pytest-twisted and deferreds
> 
> Indeed, but if I understand correctly, those tests are marked in a way that plugins will use `pytest_pyfunc_call` to intercept them and do something special with the return value.
> 
> The proposal seem to apply only for "normal" test functions, handled by pytest itself. Correct?

Should be covered by a collections.abc.Awaitable check.

Edit: Yup deferreds are already checked for here: https://github.com/pytest-dev/pytest/blob/5cfd7c0ddd5b1ffc111399e2d118b243896827b0/src/_pytest/python.py#L185
interestingly enough, `unittest` in cpython now warns in this situation: https://github.com/python/cpython/pull/27748