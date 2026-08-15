note, this should be a opt in via config, potentially by naming a policy, as dropping everything passed by default changes the debug-ability when  one wants to compare passed stuff to failed stuff
> note, this should be a opt in via config, potentially by naming a policy, as dropping everything passed by default changes the debug-ability when one wants to compare passed stuff to failed stuff

Oh really? I haven't thought about that use case.

What should be the name of the option? How about `temp_dir_retention_policy=failed|all|none`, defaulting to `all`?
Let's think a bit more about what variants we want, then we can pick a name 
thanks. this seems like it would be a really cool addition!
> Let's think a bit more about what variants we want, then we can pick a name

Fair enough.

The ones I thought were:

* Keep directories for all tests (current behavior)
* Keep directories for failed tests
* Never keep any directories

Other use cases come to mind?
nothing yet, however i haven't yet put my thoughts onto having `tmp_dir` as session and module/package scope fixture yet
> however i haven't yet put my thoughts onto having tmp_dir as session and module/package scope fixture yet

Not sure I follow... this proposal is not about changing the scope of the tmpdir fixture, just configuring how often/when it deletes old temporary directories... or am I missing something?
The proposal is only about the policy but for finding a good name im thinking about a future change /feature 
For those that need it, I adjusted https://github.com/pytest-dev/pytest/blob/28e8c8582ea947704655a3c3f2d57184831336fd/src/_pytest/tmpdir.py#L25

and I think this gives some control to acheive the desired effect in different circumstances.

<details>


```python
import pytest
import re
import shutil
import os


cleanup_tmp_path_on_success = os.environ.get("PYTEST_CLEANUP_TMP_PATH_ON_SUCCESS", "true")
cleanup_tmp_path_on_success = cleanup_tmp_path_on_success.lower()
if cleanup_tmp_path_on_success in ["1", "true"]:
    cleanup_tmp_path_on_success = True
else:
    cleanup_tmp_path_on_success = False

@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    # execute all other hooks to obtain the report object
    outcome = yield
    rep = outcome.get_result()

    # set a report attribute for each phase of a call, which can
    # be "setup", "call", "teardown"

    setattr(item, "rep_" + rep.when, rep)

def _mk_tmp(request, factory):
    name = request.node.name
    name = re.sub(r"[\W]", "_", name)
    MAXVAL = 30
    name = name[:MAXVAL]
    return factory.mktemp(name, numbered=True)

@pytest.fixture
def tmp_path(request, tmp_path_factory):
    from pathlib import Path
    import tempfile
    path = _mk_tmp(request, tmp_path_factory)
    yield path
    if cleanup_tmp_path_on_success:
        if request.node.rep_setup.failed:
            # If things failed during setup, just cleanup, the main test
            # likely didn't create anything usefil
            shutil.rmtree(path)
        elif request.node.rep_setup.passed and request.node.rep_call.passed:
            shutil.rmtree(path)
```

</details>
Is this still considered to be implemented? If so, can we get things going?
Once the naming discussion settles, I can contribute if needed.
It has not advanced I'm afraid.

My proposal:

```markdown
**Config option**: `tmp_path_retention_count`

How many sessions should we keep the `tmp_path` directories, according to `tmp_path_retention_policy`.

Default: 3

**Config option**: `tmp_path_retention_policy`

Controls which directories created by the `tmp_path` fixture are kept around, based on test outcome.

One of:

* `all`: retains directories for all tests, regardless of the outcome.
* `failed`: retains directories only for tests with outcome `error` or `failed`.
* `none`: directories are always removed after each test ends, regardless of the outcome.

Default: `failed`
```
Thank you. IMHO, it sounds good.
Just to make sure, does `tmp_path_retention_count` apply to both `all` and `failed`?

So are we good with the configuration naming or still waiting for something?
> Just to make sure, does tmp_path_retention_count apply to both all and failed?

Yes. 👍 

> So are we good with the configuration naming or still waiting for something?

I think we should wait for other maintainers to manifest if we should go forward with this or not. cc @RonnyPfannschmidt @bluetech @The-Compiler @asottile 
proposal seems fine, I'd love to be more aggressive and set the default to `failed` personally
Seems fine to me!
i strongly prefer the `all` option as default as its what allows debugging the most easy
I don't really see the value of all, seems rare-to-never that you'd debug a _passing_ test
its occasionally very helpful to diff folders of passed and failed parameters and most of the time the cost of just cleaning it up together later is not that big

also sometimes the pass is a surprise 
so why eagerly cleanup unless you have a painfully expensive "dump"

I'd wager almost none of our users even know about pytest persisting temp until they run out of disk 
@asottile i concede, thanks for reminding me, now going on the principle of least surprise lets indeed migrate towards only keeping failures as the starting point
OK, updated the proposal text to change the default to `failed`
Now we just need a volunteer to implement it. :grin: 
Wow it has been so fast!

> Now we just need a volunteer to implement it. :grin: 

Ok I got this.