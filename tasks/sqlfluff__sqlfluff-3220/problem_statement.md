Config for fix_even_unparsable not being applied
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

When setting the any config file to `fix_even_unparsable = True` the config get's overriden by the default (or lack thereof) on the @click.option decorator for the fix command.

### Expected Behaviour

When setting the config `fix_even_unparsable` it should be captured by the fix command as well.

### Observed Behaviour

The `fix_even_unparsable` command is not being captured by the fix command

### How to reproduce

Create a config file and include `fix_even_unparsable`
Run `sqlfluff fix`
Note that `fix_even_unparsable` is set to False at runtime

### Dialect

Any

### Version

0.13.0

### Configuration

`pyproject.toml`

```
[tool.sqlfluff.core]
verbose = 2
dialect = "snowflake"
fix_even_unparsable = true
```

### Are you willing to work on and submit a PR to address the issue?

- [X] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

