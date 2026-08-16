Return codes are inconsistent
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

Working on #3431 - I noticed that we're inconsistent in our return codes.

In `commands.py` we call `sys.exit()` in 15 places (currently).

- Twice we call `sys.exit(0)` on success, at the end of `parse` and `lint` (`fix` is a handled differently, see below). ✔️ 
- Six times we call `sys.exit(1)` for a selection of things:
  - Not having `cProfiler` installed.
  - Failing to apply fixes
  - User Errors and OSError (in `PathAndUserErrorHandler`)
- Five times we call `sys.exit(66)` for a selection of things:
  - User Errors (including unknown dialect or failing to load a dialect or config)
  - If parsing failed when calling `parse`.
- Once we use `handle_files_with_tmp_or_prs_errors` to determine the exit code (which returns 1 or 0)
- Once we use `LintingResult.stats` to determine the exit code (which returns either 65 or 0)
- Once we do a mixture of the above (see end of `fix`)

This neither DRY, or consistent ... or helpful?

### Expected Behaviour

We should have consistent return codes for specific scenarios. There are up for discussion, but I would suggest:

- 0 for success (obviously)
- 1 for a fail which is error related: not having libraries installed, user errors etc...
- 65 for a linting fail (i.e. no errors in running, but issues were found in either parsing or linting).
- 66 for a fixing fail (i.e. we tried to fix errors but failed to do so for some reason).

These would be defined as constants at the top of `commands.py`.

### Observed Behaviour

see above

### How to reproduce

see above

### Dialect

N/A

### Version

Description is as per code in #3431

### Configuration

-

### Are you willing to work on and submit a PR to address the issue?

- [X] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

