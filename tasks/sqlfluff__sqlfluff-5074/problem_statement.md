Inconsistent output depending on --processes flag when --ignore linting is used
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

Depending on the value you set for the `--processes` flag when also using `--ignore linting`, different output with different exit codes are generated.

### Expected Behaviour

The same exit code should be generated, independently of the `--processes` flag. Furthermore, from https://docs.sqlfluff.com/en/stable/production.html#using-sqlfluff-on-a-whole-sql-codebase I would expect that exit codes should be either `0` or `65`, not `1`.

### Observed Behaviour

See the How to reproduce section.

### How to reproduce

Create a `test.sql` file with the following content:

```SQL
CREATE TABLE example (
    id TEXT DEFAULT 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. In condimentum congue est, ac orci aliquam.' PRIMARY KEY
);
```

The line is too long according to SQLFluff, caused by the large default value, so let's see the the output of SQLFluff.

Running

```SHELL
sqlfluff fix --dialect postgres --ignore linting --processes 2
```

results in 

```
==== finding fixable violations ====
==== no fixable linting violations found ====                                                                                                                                                                      
All Finished 📜 🎉!
  [1 unfixable linting violations found]
```

with exit code `1`. Running the same with one process instead:

```SHELL
sqlfluff fix --dialect postgres --ignore linting --processes 1
```

results in

```
==== finding fixable violations ====
==== no fixable linting violations found ====                                                                                                                                                                      
All Finished 📜 🎉!
```

and exit code `0`

Same behaviour for `lint` and `format` commands.

### Dialect

Postgres

### Version

2.2.0, Python 3.10.6

### Configuration

None, it's all in the CLI flags.

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

