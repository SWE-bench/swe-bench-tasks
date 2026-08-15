Thanks for opening an issue @stanislavlevin I agree, we should communicate this better. I think we should check that it's still the case, and if so, we should add some runtime warnings to make it more obvious (or maybe raising an error when we detect custom plugins and the parallel mode).
Original ticket:
https://pagure.io/freeipa/issue/8116
This is still the case - I just spent some time figuring out why my plugin was not loading and found those docs eventually. A warning would have helped greatly.

cc @PCManticore 
I've started work on this and got
```
        if linter.config.jobs >= 0:
            if self._plugins:
                warnings.warn(
                    "Running pylint in parallel with custom plugins is not currently supported.",
                    UserWarning,
                )
                # sys.exit(32)
```

but wanted to check if we want both a warning and a crash (sys.exit) or just a warning. With the crash I have to update quite a few tests so I wanted to make sure before investing that time.
Tagging @Pierre-Sassoulas for an opinion on this!
I'm not super up to date on this issue but imo if the result would be rubbish and plain wrong we need to crash, if it's still usable with a possible issue and we're not sure about it then we should warn. 
Given original statement

>Unfortunately, linting results are not the same as a single process linting, but Pylint silently pass. So, results are not predictable.

sounds like we should indeed crash.
I'm not sure the issue hasn't been resolved in the meantime.

Home-Assistant uses `-j 2` be default, even for all CI runs, and also uses custom plugins. There has been the occasional unstable result, but that wasn't because of custom plugins. Rather a result of the way files are passed to works in an unpredictable order which results in different astroid caches for different worker processes.

Of course that's probably exaggerated at -j 32/64. Maybe instead of adding a `UserWarning` we should instead update the documentation to suggest using a lower number. We could also limit the default to `2` or `4`. That's enough for most projects.
I thought the most severe problem was #4874, and as far as I know, it's still applicable.
> Rather a result of the way files are passed to works in an unpredictable order which results in different astroid caches for different worker processes.

This one should be fixed in #7747 hopefully.

> I thought the most severe problem was https://github.com/PyCQA/pylint/issues/4874,

Indeed and there's of course #2525 which coupled with the small problem of multiprocessing make multiprocessing not worth the small benefit it bring.
Sounds like we should still fix this issue then. Do we agree on both raising a UserWarning and exiting pylint? And we're talking about the case when jobs is 0 OR any positive number other than 1, correct?
> Do we agree on both raising a UserWarning and exiting pylint? And we're talking about the case when jobs is 0 OR any positive number other than 1, correct?

I would say yes because the exit code could be 0 because of an issue with the processing.
Hm, as @cdce8p mentions this isn't really an issue for basic plugins. I expect this would slow down the home assistant CI considerably and also have personal CIs that would get slowed down.

Can we detect if it is a transform plugin?
@DanielNoord doesn't seem like this is the same conclusion reached above by the other 2 maintainers. What do you all think? @Pierre-Sassoulas  @jacobtylerwalls ?
I like Daniel's idea, actually. Don't know if it's feasible but sounds promising.
> Can we detect if it is a transform plugin?

What is a transform plugin?
A plugin that calls `register_transform`: see [extending docs in astroid](https://pylint.pycqa.org/projects/astroid/en/latest/extending.html).

The transforms are stored on the `AstroidManager` object, stored at `pylint.lint.MANAGER`. Maybe compare a before and after snapshot of the the transform registry before and after forking?
If not possible, I would suggest trying to find a way to show this warning more explicitly without crashing. This would really hurt the adoption of newer versions by companies/projects that have their own little plugins. I think the people we would annoy with this without reason vs. the people that are actually helped by this is not really balanced.
True, it might be worth investing the extra effort of doing the snapshots (versus just doing a warning) in fixing the root problem in #4874 instead....
Doesn't this all fall down to us using a single Manager instance for all processes which breaks both transform plugins and creates interdependencies for processes?
We might be investing time in fixing a broken multiprocessing approach..
Sounds like the scope of this issue has changed. I'll close the PR and let maintainers update the title and summarize the new requirements.
I think a warning would be acceptable. Doesn't sound like there's consensus for raising an exception at this juncture.