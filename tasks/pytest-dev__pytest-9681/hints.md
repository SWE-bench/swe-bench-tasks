Bisected to b706a2c04840a8057610f41071fbcf3da1290eb5 (PR #7870), cc @nicoddemus.
Hi @bluenote10, 

Thanks for the detailed report, we definitely appreciate it.

> What's particularly surprising: The example works, when renaming the conftest.py to e.g. conftest2.py

That's because `conftest2.py` are not special to pytest, while `conftest.py` files are handled specially. But I can see why it might seem surprising at first. 👍 

> Imports like this used to work with pre 7 pytest versions in importlib mode despite the existence of a conftest.py.

Just to clarify to make sure we are not missing anything: `pythonpaths` was added in 7.0.0, so `pythonpaths` in the `pytest.ini` had no effect in prior versions. How did you configure the PYHONPATH in pytest<7, with the directory layout you posted?
> Just to clarify to make sure we are not missing anything: pythonpaths was added in 7.0.0, so pythonpaths in the pytest.ini had no effect in prior versions. How did you configure the PYHONPATH in pytest<7, with the directory layout you posted?

Indeed, pre 7.0.0 we did nothing special at all to import from `tests` irrespective of the import mode, but we need to use the recommended `importlib` for some internal reasons.

I've only added `pythonpath = .` (note: not `pythonpaths`, which was the name used by the old plugin) to be fully explicit, in the hope that pytest will then allow to import from all the top-level folders like `tests`. Most likely this is the default behaviour anyway, and the problem hasn't anything to do with `pythonpath` at all (when not specifying it the import fails as well).
OK, thanks.

So to be crystal clear: if we remove `pythonpath` from your example, then running the command `pytest` in pytest 6 **works**, but in pytest 7 it **does not work**, giving the `ModuleNotFoundError` above, right?

(Sorry if I'm being pedantic, but having an accurate understanding is important)
> So to be crystal clear: if we remove pythonpath from your example, then running the command pytest in pytest 6 works, but in pytest 7 it does not work, giving the ModuleNotFoundError above, right?

This is exactly what we are observing with our actual project: We tried to update from pytest 6.2.5 to 7.0.0 and all of a sudden all imports towards `tests.<test-package>` fail with `ModuleNotFoundError`. The only related non-standard option we are using is the `importlib` mode.

Unfortunately, the reproduction example doesn't seem to fully reflect that, because it also fails with pytest < 7 😞 I need to further investigate why this actually used to work in our real project at all. So I'm no longer fully sure whether it is truly a 7.0 regression. In any case importing from `tests` used to work, and in particular when specifying `pythonpath = .` in 7.0, it probably should according to the documentation.
Ahh OK thanks.

>  In any case importing from tests used to work, and in particular when specifying pythonpath = . in 7.0, it probably should according to the documentation.

I agree, I will investigate. Thanks again.
I tested it with `PYTHONPATH=.`