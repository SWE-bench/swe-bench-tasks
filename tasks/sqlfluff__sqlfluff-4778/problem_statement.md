2.0.2 - LT02 issues when query contains "do" statement.
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

SQLFluff v2.0.2 gives LT02 indentation errors for the Jinja `if`-block when `template_blocks_indent` is set to `True`.
The example SQL below is a bit contrived, but it's the smallest failing example I could produce based on our real SQL.

If I remove the Jinja `do`-expression from the code, the `if` block validates without errors.

### Expected Behaviour

I expect the SQL to pass the linting tests.

### Observed Behaviour

Output from SQLFluff v2.0.2:
```
L:   5 | P:   1 | LT02 | Line should not be indented.
                       | [layout.indent]
L:   6 | P:   1 | LT02 | Line should not be indented.
                       | [layout.indent]
```

### How to reproduce

SQL to reproduce:
```
{% set cols = ['a', 'b'] %}
{% do cols.remove('a') %}

{% if true %}
    select a
    from some_table
{% endif %}
```

### Dialect

`ansi`

### Version

```
> sqlfluff --version
sqlfluff, version 2.0.2

> python --version
Python 3.9.9
```

### Configuration

```
[sqlfluff]
dialect = ansi
templater = jinja

[sqlfluff:indentation]
template_blocks_indent = True
```

### Are you willing to work on and submit a PR to address the issue?

- [X] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

2.0.2 - LT02 issues when query contains "do" statement.
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

SQLFluff v2.0.2 gives LT02 indentation errors for the Jinja `if`-block when `template_blocks_indent` is set to `True`.
The example SQL below is a bit contrived, but it's the smallest failing example I could produce based on our real SQL.

If I remove the Jinja `do`-expression from the code, the `if` block validates without errors.

### Expected Behaviour

I expect the SQL to pass the linting tests.

### Observed Behaviour

Output from SQLFluff v2.0.2:
```
L:   5 | P:   1 | LT02 | Line should not be indented.
                       | [layout.indent]
L:   6 | P:   1 | LT02 | Line should not be indented.
                       | [layout.indent]
```

### How to reproduce

SQL to reproduce:
```
{% set cols = ['a', 'b'] %}
{% do cols.remove('a') %}

{% if true %}
    select a
    from some_table
{% endif %}
```

### Dialect

`ansi`

### Version

```
> sqlfluff --version
sqlfluff, version 2.0.2

> python --version
Python 3.9.9
```

### Configuration

```
[sqlfluff]
dialect = ansi
templater = jinja

[sqlfluff:indentation]
template_blocks_indent = True
```

### Are you willing to work on and submit a PR to address the issue?

- [X] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

