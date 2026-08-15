IMO this is a bug.

This happens before the `-k` expression is evaluated using `eval`, `1` and `2` are evaluated as numbers, and `1 or 2` is just evaluated to True which means all tests are included. On the other hand `_1` is an identifier which only evaluates to True if matches the test name.

If you are interested on working on it, IMO it would be good to move away from `eval` in favor of parsing ourselves. See here for discussion: https://github.com/pytest-dev/pytest/issues/6822#issuecomment-596075955
@bluetech indeed! Thanks for the pointer, it seems to be really the same problem as the other issue.