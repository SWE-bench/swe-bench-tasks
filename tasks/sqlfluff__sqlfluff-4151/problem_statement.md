--disable_progress_bar Flag Broken for Fix
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

I ran `sqlfluff fix ${target} --dialect ansi --disable_progress_bar --force` on version 1.4.0 and got an error with exit code 2. Running with `--disable-progress-bar` appears to work fine, but it appears that compatibility with underscores was broken in version 1.4.0.

### Expected Behaviour

Should run as expected, with no error and no progress bar.

### Observed Behaviour

Exit code 2 and stderr:
```
Usage: sqlfluff fix [OPTIONS] [PATHS]...
        Try 'sqlfluff fix -h' for help.

        Error: No such option: --disable_progress_bar (Possible options: --disable-noqa, --disable-progress-bar)
```

### How to reproduce

Sql file:
```
SELECT foo FROM bar;
```

Command:
```
sqlfluff fix ${target} --dialect ansi --disable_progress_bar --force
```

### Dialect

ansi

### Version

python 3.10.3
sqlfluff 1.4.0 and up appears to have this problem (tested through 1.4.2)

### Configuration

No special configuration. Ran hermetically with `trunk`.

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

--disable_progress_bar Flag Broken for Fix
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

I ran `sqlfluff fix ${target} --dialect ansi --disable_progress_bar --force` on version 1.4.0 and got an error with exit code 2. Running with `--disable-progress-bar` appears to work fine, but it appears that compatibility with underscores was broken in version 1.4.0.

### Expected Behaviour

Should run as expected, with no error and no progress bar.

### Observed Behaviour

Exit code 2 and stderr:
```
Usage: sqlfluff fix [OPTIONS] [PATHS]...
        Try 'sqlfluff fix -h' for help.

        Error: No such option: --disable_progress_bar (Possible options: --disable-noqa, --disable-progress-bar)
```

### How to reproduce

Sql file:
```
SELECT foo FROM bar;
```

Command:
```
sqlfluff fix ${target} --dialect ansi --disable_progress_bar --force
```

### Dialect

ansi

### Version

python 3.10.3
sqlfluff 1.4.0 and up appears to have this problem (tested through 1.4.2)

### Configuration

No special configuration. Ran hermetically with `trunk`.

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

