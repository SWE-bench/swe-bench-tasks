TypeError when using integer placeholder
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

An exception occurs when trying to use integer substituents.

### Expected Behaviour

Work without errors.

### Observed Behaviour


An exception occurs:
```
  ...
  File "venv/lib/python3.9/site-packages/sqlfluff/core/linter/linter.py", line 816, in render_file
    return self.render_string(raw_file, fname, config, encoding)
  File "venv/lib/python3.9/site-packages/sqlfluff/core/linter/linter.py", line 787, in render_string
    templated_file, templater_violations = self.templater.process(
  File "venv/lib/python3.9/site-packages/sqlfluff/core/templaters/placeholder.py", line 183, in process
    start_template_pos, start_template_pos + len(replacement), None
TypeError: object of type 'int' has no len()

```

### How to reproduce

1. Create a file `example.sql`:
```
SELECT 1
LIMIT %(capacity)s;
```
2. Copy `.sqlfluff` from the Configuration section
3. Run `sqlfluff lint --dialect postgres example.sql`

### Dialect

postgres

### Version

sqlfluff, version 0.13.1

### Configuration

```
[sqlfluff]
exclude_rules = L031
templater = placeholder

[sqlfluff:templater:placeholder]
param_style = pyformat
capacity = 15
```

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

Support Postgres-style variable substitution
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### Description

The Postgres `psql` utility supports flavor of colon-style variable substitution that currently confuses sqlfluff.  E.g.,

```sql
ALTER TABLE name:variable RENAME TO name;
```

Running the above through sqlfluff produces this output:

```
sqlfluff lint --dialect postgres 2.sql
== [2.sql] FAIL
L:   1 | P:   1 |  PRS | Line 1, Position 1: Found unparsable section: 'ALTER
                       | TABLE name:variable RENAME TO name...'
```

### Use case

I would like it if in the above the string "name:variable" were considered a valid table name (and other identifiers similarly).

### Dialect

This applies to the Postgres dialect.

### Are you willing to work on and submit a PR to address the issue?

- [X] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

