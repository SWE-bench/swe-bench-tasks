Thanks for the report. At a glance, that looks very plausible.. Test and patch welcome
I'm happy to do this although would be interested in opinions on the test. I could do either

1) Test what causes the bug above i.e. the model doesn't converge when warm starting.
2) Test that the initial `w0` used in `logistic_regression_path` is the same as the previous `w0` after the function has been run i.e. that warm starting is happening as expected.

The pros of (1) are that its quick and easy however as mentioned previously it doesn't really get to the essence of what is causing the bug. The only reason it is failing is because the `w0` is getting initialised so that the rows are exactly identical. If this were not the case but the rows also weren't warm started correctly (i.e. just randomly initialised), the model would still converge (just slower than one would hope if a good warm start had been used) and the test would unfortunately pass.

The pros of (2) are that it would correctly test that the warm starting occurred but the cons would be I don't know how I would do it as the `w0` is not available outside of the `logistic_regression_path` function.
Go for the simplest test first, open a PR and see where that leads you!