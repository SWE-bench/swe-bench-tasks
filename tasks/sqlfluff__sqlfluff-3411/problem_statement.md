Update warning for parsing errors found on the ansi dialect
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### Description

In the past specifying a dialect was **optional**. If unspecified, the dialect defaulted to `ansi`. Because of this there is a warning presented when sqlfluff runs in parse mode and the dialect is set to ansi and parsing errors are encountered.

`WARNING: Parsing errors found and dialect is set to 'ansi'. Have you configured your dialect?`

Currently, specifying a dialect is **mandatory**. Therefore this warning is perhaps not needed... and certainly not needed in its current form.

I opened this issue to document the idea and solicit feedback. 
1. The simplest improvement to make the message more appropriate is to just change it to this:

`WARNING: Parsing errors found and dialect is set to 'ansi'. Is 'ansi' the correct dialect?`

2. On the other hand, we know that the user explicitly set the dialect to `ansi`. So why bother asking if it was intentional? We don't ask if you meant postgres or tsql. There's an argument to simply remove the warning altogether.

3. Finally, we could potentially differentiate between `--dialect ansi` passed on the command line vs the dialect being picked up from a `.sqlfluff` config file. Perhaps the warning should be displayed only the in the case where the dialect was picked up implicitly from the config file.

### Use case

_No response_

### Dialect

ansi

### Are you willing to work on and submit a PR to address the issue?

- [X] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

