Standardise `--disable_progress_bar` naming
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

As noted in https://github.com/sqlfluff/sqlfluff/pull/3610#discussion_r926014745 `--disable_progress_bar` is the only command line option using underscores instead of dashes.

Should we change this?

This would be a breaking change, so do we leave until next major release?
Or do we accept both options?

### Expected Behaviour

We should be standard in out command line option format

### Observed Behaviour

`--disable_progress_bar` is the only non-standard one

### How to reproduce

N/A

### Dialect

N/A

### Version

1.2.1

### Configuration

N/A

### Are you willing to work on and submit a PR to address the issue?

- [X] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

