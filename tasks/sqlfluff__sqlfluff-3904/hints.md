I like the idea (of at least as a transition) or accepting both, but then defaulting to the one consistent with the other options.
So this is about changing option `--disable_progress_bar` to `--disable-progress-bar`, right? I think I can take care of that, it was me who introduced it here :)

Additionally I would make an attempt to have these two options available, but to nicely inform users that one with underscores is deprecated. What do you think @tunetheweb? 

I see I cannot assign myself to that Issue.

> So this is about changing option `--disable_progress_bar` to `--disable-progress-bar`, right? I think I can take care of that, it was me who introduced it here :)

Correct and thanks for taking on

> Additionally I would make an attempt to have these two options available, but to nicely inform users that one with underscores is deprecated. What do you think @tunetheweb?

@alanmcruickshank added some functionality that might help in #3874 but not sure if that applies to command lines options too (I’m having less time to work on SQLFluff lately so not following it as closely as I used to). If not maybe it should?

> I see I cannot assign myself to that Issue.

Yeah only maintainers can assign, which is a bit of an annoying restriction of GitHub so we tend not to use that field and commenting (like you’ve done here) is sufficient to claim an issue. Please comment again if to “unassign” yourself if it turns out you won’t be able to work on it after all. Though lack of progress is a usually good indicator of that anyway 😄