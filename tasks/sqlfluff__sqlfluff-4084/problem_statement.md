Multiple processes not used when list of explicit filenames is passed
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

When providing a long list of file names to `sqlfluff lint -p -1`, only a single CPU is used. This seems to stem from the fact that https://github.com/sqlfluff/sqlfluff/blob/a006378af8b670f9235653694dbcddd4c62d1ab9/src/sqlfluff/core/linter/linter.py#L1190 is iterating over the list of files. For each listed path there, it would run the found files in parallel. As we are inputting whole filenames here, a path equals a single file and thus `sqlfluff` would only process one file at a time.

The context here is the execution of `sqlfluff lint` inside a `pre-commit` hook.

### Expected Behaviour

All CPU cores are used as `-p -1` is passed on the commandline.

### Observed Behaviour

Only a single CPU core is used.

### How to reproduce

Run `sqlfluff lint -p -1` with a long list of files.

### Dialect

Affects all. 

### Version

1.4.2

### Configuration

None.

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

