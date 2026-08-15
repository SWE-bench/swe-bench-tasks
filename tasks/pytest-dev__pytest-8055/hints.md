Also running `gc.collect()` after every test and before resetting the hook can help spot which tests left unclosed files etc.

This may be something dedicated to a special mode - eg by default run gc.collect() at the end of the session, and print a message saying to enable the special mode to discover which test caused the problem
There are also sys.excepthook and threading.excepthook (new in Python 3.8). Collecting gc.collect() can slow down tests, but it helps to get the error reported in the correct test. Otherwise, an error (like a ResourceWarning) could be logged 1, 2 or 3 tests later which makes no sense when you look at the error. It happens to me frequently when I debug issues in Python buildbots (I'm maintaining the Python upstream CI, Python core & stdlib).

I would suggest to only emit warnings, not get the tests fail, by default. Otherwise, I'm sure that many projects will be able to run their test suite anymore :-)

It's like trying to run a test suite using -Werror... good luck with that :-)
This will be nice to have.

I think it should be straightforward to experiment with using a plugin. Some things the plugin might do are:

- Set `sys.unraisablehook` for setup/call/teardown.
- Set `threading.excepthook` for setup/call/teardown.
- Add `gc.collect()` calls at appropriate times. Should probably be optional, default off, due to overhead. But can be enabled when want to debug `ResourceWarning`s.
- Enable tracemalloc -- IIRC this makes `ResourceWarning`s more informative. Probably also default off due to overhead?

(`sys.excepthook` I think is not relevant since pytest would catch any exception which propagates).

Some questions are:
- Are we OK taking features which don't work on all Python versions we support? If so, should it just no-op on these versions, or error?
- What to do when a hook is triggered - failure, error, warning, make it configurable?
`sys.excepthook` is relevant for threads that interact with the tes
i think it should be configurable

its not clear to me what we should do on python versions without the features
> 
> 
> This will be nice to have.
> 
> I think it should be straightforward to experiment with using a plugin. Some things the plugin might do are:

maybe we should close this issue as "do it in a plugin"

> 
>     * Set `sys.unraisablehook` for setup/call/teardown.
> 
>     * Set `threading.excepthook` for setup/call/teardown.

we should set the sys.unraisablehook once at import time, and then handle hook calls in pytests' own context management

>     * Add `gc.collect()` calls at appropriate times. Should probably be optional, default off, due to overhead. But can be enabled when want to debug `ResourceWarning`s.
> 
>     * Enable tracemalloc -- IIRC this makes `ResourceWarning`s more informative. Probably also default off due to overhead?
> 
> 
> (`sys.excepthook` I think is not relevant since pytest would catch any exception which propagates).
> 
> Some questions are:
> 
>     * Are we OK taking features which don't work on all Python versions we support? If so, should it just no-op on these versions, or error?

Doesn't (didn't) pytest already do this?

>     * What to do when a hook is triggered - failure, error, warning, make it configurable?

I think we can process hook calls separately during setup, call and teardown


I've created a branch with plugins for unraisablehook and threading.excepthook: https://github.com/bluetech/pytest/commits/unraisable

Still need to iron out some issues and polish it, then I will submit a PR for consideration.