Sounds reasonable. 👍 
Hi! I would like to work on this proposal. I went ahead and modified `pytester.RunResult.assert_outcomes()` to also compare the `deselected` count to that returned by `parseoutcomes()`. I also modified `pytester_assertions.assert_outcomes()` called by `pytester.RunResult.assert_outcomes()`.

While all tests pass after the above changes, I think none of the tests presently would be using `assert_outcomes()` with deselected as a parameter since it's a new feature, so should I also write a test for the same?  Can you suggest how I should go about doing the same? I am a bit confused as there are many `test_` files.

I am new here, so any help/feedback will be highly appreciated. Thanks!
Looking at the [pull request 8952](https://github.com/pytest-dev/pytest/pull/8952/files) would be a good place to start.
That PR involved adding `warnings` to `assert_outcomes()`, so it will also show you where all you need to make sure to have changes.
It also includes a test. 
The test for `deselected` will have to be different.
Using `-k` or `-m` will be effective in creating deselected tests.
One option is to have two tests,  `test_one` and `test_two`, for example, and call `pytester.runpytest("-k", "two")`.
That should produce one passed and one deselected.
One exception to the necessary changes. I don't think `test_nose.py` mods would be necessary. Of course, I'd double check with @nicoddemus.
didn't mean to close