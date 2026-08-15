Looks to be a result of https://github.com/pandas-dev/pandas/pull/49101/files

Seems like we have to change to `origin` or `offset` somewhere
Yes, I think so too.  I can look into it more this weekend.  Clearly we need to change the code that relies on pandas immediately.  For resampling with a `CFTimeIndex` I may create a separate issue for implementing these new arguments (we can probably get those tests passing in the meantime, however).
We also still have https://github.com/pydata/xarray/issues/6985 open.

Maybe we should try to catch Deprecation warnings in the nightly builds and raise an error / Automatic issue, so we can fix things before they break.
I went ahead and actually implemented the `origin` and `offset` options for the `CFTimeIndex` version of resample as part of #7284.  It might be good to finish that and then we can decide how we would like to handle the deprecation.

> Maybe we should try to catch Deprecation warnings in the nightly builds and raise an error / Automatic issue, so we can fix things before they break.

I agree -- something like that would be useful in general.  In this particular case it seems like we were aware of it at one point, but just lost track after silencing it initially for compatibility reasons (https://github.com/pydata/xarray/pull/4292#issuecomment-691665611).  Unfortunately that means that this was silenced in user code as well.
Perhaps we can at least restore the warning in #7284 in case our next release happens to take place before the next pandas release to give users somewhat of a heads up.  Apologies for being a bit out of the loop of #4292 at the time.
maybe we can extend the action / create a new one to open one issue per unique deprecation message. However, for that we'd need to log the warnings in the `reportlog` output, which as far as I can tell `pytest-reportlog` does not support at the moment.
we've got a few more errors now:
```
TypeError: DatetimeArray._generate_range() got an unexpected keyword argument 'closed'
```

I've renamed this issue to allow tracking more recent failures in new issues.
Should we add some sort of deprecation warning regarding the use of the `base` argument with future versions of pandas before the next release?

(I did not end up restoring the pandas warning in #7284)
> Should we add some sort of deprecation warning regarding the use of the base argument with future versions of pandas before the next release?

That would be nice. It seems like we could also just do it in a later release?
Sorry I didn't get to adding the warning today.  I'll try and put something together over the weekend so that it gets into the release after today's.  I'm not sure exactly when pandas 2.0 will be out, but regardless I guess at least it could still be valuable for anyone who doesn't upgrade xarray and pandas at the same time.
As I think about this more, it wouldn't be too hard for us to support the `base` argument even after pandas removes it, so perhaps this isn't so urgent (at least as far as deprecation is concerned; we still need to make updates for compatibility, however).  The code to translate a `base` argument to an `offset` argument can be found [here](https://github.com/pandas-dev/pandas/blob/bca35ff73f101b29106111703021fccc8781be7a/pandas/core/resample.py#L1668-L1678), and is all possible with public API functionality.  I already did something similar for the CFTimeIndex resampling code in #7284.

Maybe you were already thinking along those lines @dcherian.