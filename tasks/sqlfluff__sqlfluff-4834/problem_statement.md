Running `lint` on an empty file fails with critical Exception
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

This is a bit of an odd one. When running `sqlfluff lint` on an empty file it fails with (Python) exception.

While trying to lint empty file is probably not the main use-case for SQLFluff I still consider this somewhat relevant, when applying SQLFluff in a dynamic code base. 

### Expected Behaviour

I'm not entirely sure what the correct result is. Feasible option are

- Passing
- Raise some kind of lint error (but not a critical exception)

My personal take is that lint should pass, which (I think) is similar behaviour to other linters.

### Observed Behaviour

`LT01` and `LT12` with an critical Exception

```
CRITICAL   [LT01] Applying rule LT01 to 'stdin' threw an Exception: ReflowSequence has empty elements.
CRITICAL   [LT12] Applying rule LT12 to 'stdin' threw an Exception: tuple index out of range
```


### How to reproduce

```sh
cat /dev/null | sqlfluff lint --dialect ansi -
```

### Dialect

ansi

### Version

latest main branch

```
git rev-parse HEAD
d19de0ecd16d298f9e3bfb91da122734c40c01e5
```

### Configuration

default

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

Running `lint` on an empty file fails with critical Exception
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

This is a bit of an odd one. When running `sqlfluff lint` on an empty file it fails with (Python) exception.

While trying to lint empty file is probably not the main use-case for SQLFluff I still consider this somewhat relevant, when applying SQLFluff in a dynamic code base. 

### Expected Behaviour

I'm not entirely sure what the correct result is. Feasible option are

- Passing
- Raise some kind of lint error (but not a critical exception)

My personal take is that lint should pass, which (I think) is similar behaviour to other linters.

### Observed Behaviour

`LT01` and `LT12` with an critical Exception

```
CRITICAL   [LT01] Applying rule LT01 to 'stdin' threw an Exception: ReflowSequence has empty elements.
CRITICAL   [LT12] Applying rule LT12 to 'stdin' threw an Exception: tuple index out of range
```


### How to reproduce

```sh
cat /dev/null | sqlfluff lint --dialect ansi -
```

### Dialect

ansi

### Version

latest main branch

```
git rev-parse HEAD
d19de0ecd16d298f9e3bfb91da122734c40c01e5
```

### Configuration

default

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

