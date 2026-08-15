@nicoddemus i would simply put in json serialized report objects for the collect and test reports as a starting point, and start the file with a version specifying object

the subunit protocol might be sensible to take a look at, version 1 of the protocol was text based and seemed limited - version 2 is binary, framed and needs to be investigated

as for tap https://testanything.org/ - based on the docs its anything but suitable for expressing whats going on in pytest
> @nicoddemus i would simply put in json serialized report objects for the collect and test reports as a starting point, and start the file with a version specifying object

I see, that's what I had in mind as well, that's what we have now with the `resutlog.py` plugin, except it uses a custom format.

> the subunit protocol might be sensible to take a look at, version 1 of the protocol was text based and seemed limited - version 2 is binary, framed and needs to be investigated

Not sure, I particularly try to avoid binary based protocols when performance isn't really critical.

My gut feeling would be to stick to a text-based protocol (JSON), but please let me know if you have other concerns for wanting a binary protocol.

> as for tap testanything.org - based on the docs its anything but suitable for expressing whats going on in pytest

Oh I'm surprised, here is the output from the [pytest-tap README](https://github.com/python-tap/pytest-tap):

```
$ py.test --tap-stream
ok 1 - TestPlugin.test_generates_reports_for_combined
ok 2 - TestPlugin.test_generates_reports_for_files
ok 3 - TestPlugin.test_generates_reports_for_stream
ok 4 - TestPlugin.test_includes_options
ok 5 - TestPlugin.test_skips_reporting_with_no_output_option
ok 6 - TestPlugin.test_track_when_call_report
ok 7 - TestPlugin.test_tracker_combined_set
ok 8 - TestPlugin.test_tracker_outdir_set
ok 9 - TestPlugin.test_tracker_stream_set
ok 10 - TestPlugin.test_tracks_not_ok
ok 11 - TestPlugin.test_tracks_ok
ok 12 - TestPlugin.test_tracks_skip
1..12
```

It uses a custom format, but is nearly identical to the information we have today with `resultlog`, but it contains tools for parsing it which is the reason why I thought it could be suggested as a good replacement.
@nicoddemus that tap report is absolutely lossy - 
You are right, we are missing setup/teardown calls, durations...

But can you describe why you want something like `resultlog` in the core? It seems little used, because we have deprecated it for ages and not heard a pip (hah, it came out like this, I'm leaving it) about it.

I believe you have some more advanced plans for such a log file, could you please clarify this a big?
@nicoddemus i want to see report log serialization and replay in core
> @nicoddemus i want to see report log serialization and replay in core

I see, but why? For example, do you want to reuse the log in junitxml and pytest-html, or you want another command-line option to replay log files, or both? Sorry for being so much probing, just would like to know what you have in mind more clearly. 😁 
@nicoddemus as a starting point i want something that can store logs and replay them - this would also allow to do junitxml/html generation based on that artifact using replay

i don't intend to change the junitxml/html designs - they should jsut be able to work based on replays

also the ability to have certain replays should help with their acceptance tests
> @nicoddemus as a starting point i want something that can store logs and replay them - this would also allow to do junitxml/html generation based on that artifact using replay

I see, thought that as well. But that doesn't help for the cases where you don't have a "log" file in place already (the first run of the test suite where you want to have a junitxml report). I believe we would have to introduce a new "log" hook entry, so that the junitxml plugin can implement to write its own `.xml` file? Wouldn't that counter the purpose?

(Sorry if I'm sounding confrontational, it is not my intention at all, just want to have a proper glimpse of what you have in mind and discuss a solution).
@nicoddemus log writing and replay has nothing to do with new hooks, nothing for junitxml would change - it would use exactly the same hooks with the same reports, just one time those where read from a log while  the other time they are "live"
Oh I see, thanks. But wouldn't that introduce a lot of complexity to the junitxml plugin? I mean, it would need to know how to extract the information from hooks, and from the log file?

To be clear: I get you want the option to "replay" a log file, I'm discussing if there are other topics around it (like junitxml).
@nicoddemus again - junitxml will not care about logs or know about them - it sees the same hooks in both situations
I've come across one use case where resultlog is/was handy, but junitxml doesn't work so well. We have a system which runs tests on code submitted by students and then provides them feedback. The tests are run in a separate process, and forcefully terminated if they don't complete within a time limit. Resultlog is written as the tests proceed, so it details which tests already ran before the time limit, whereas junitxml is written only when the tests are complete.

It sounds like the JSON-based logging you're thinking about here will meet our needs nicely, so long as the events are written (and ideally flushed) as they are created. As you're intending to do this before removing resultlog, I'll probably suppress the deprecation warning for now and keep using resultlog until the replacement is ready.

But now you've heard a pip. :slightly_smiling_face: 
> The tests are run in a separate process, and forcefully terminated if they don't complete within a time limit. Resultlog is written as the tests proceed, so it details which tests already ran before the time limit, whereas junitxml is written only when the tests are complete.

If pytest wasn't forcefully killed, at least initially, but through an internal timeout the junitxml output might still be generated.  No experience with that though, only stumbled upon https://pypi.org/project/pytest-timeout/, which also appears to kill it forcefully.
Might be a good motivation for a global `--timeout` option, and/or handling e.g. SIGTERM to still write the junit output, as if the test run was interrupted.
We could certainly try to do things like that if necessary, but it gets involved, because you have to first try soft-killing the process (e.g. SIGTERM), then wait again to see if it terminates, then be prepared to kill it forcefully if not. And you still can't rely on the junit output being there, because you might have had to forcefully kill it.

I think it's logically impossible to reliably impose a timeout *and* ensure that the process can cleanly shut down, because the shutdown steps may take an arbitrary amount of time.
Yes, I see (and it makes sense in general) - just wanted to provide some input to improve this on pytest's side.
@takluyver thanks for the pip. 😁 

FTR the initial workings are in place at #4965.
Please dont remove --resultlog
Hi @LEscobar-Driver,

Could you please provide more context where you use resultlog, and why the alternative we propose here wouldn't fit your use case? 
Btw, what should be name of the new module and option? Suggestions? 🤔 
`report-log` or `testrun-trace`come to mind
`report-log` is good, a little too similar to `result-log`, but I don't have a better suggestion. It also will convey better the output, which should be in essence "report objects serialized".
I just noticed the deprecation notice in the PyPy buildbot test runs. We have a [parser](https://bitbucket.org/pypy/buildbot/src/50ceac4fc422e11a0fcd39c560e7aca54c336c6c/bot2/pypybuildbot/summary.py#lines-114) that parses the result-log to populate a report and would need to be rewritten for any breaking changes. How can we prepare for this unwanted deprecation?
Hi @mattip,

We plan to introduce a new option and only much later actually remove result-log. 