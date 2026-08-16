Deduplicate violations in the same position
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### Description

When linting jinja files with loops we get multiple output violations for each time around the loop. e.g.

```sql
select
    a,
    {% for val in [1, 2, 3, 4, 5, 6] %}
        d+ {{ val }},
    {% endfor %}
    b
```

we get

```
== [test.sql] FAIL
L:   4 | P:  10 | L006 | Missing whitespace before +
L:   4 | P:  10 | L006 | Missing whitespace before +
L:   4 | P:  10 | L006 | Missing whitespace before +
L:   4 | P:  10 | L006 | Missing whitespace before +
L:   4 | P:  10 | L006 | Missing whitespace before +
L:   4 | P:  10 | L006 | Missing whitespace before +
L:   7 | P:   1 | L001 | Unnecessary trailing whitespace.
```

The duplicated `Missing whitespace` isn't helpful for the user. Regardless of whether we keep them in the background (perhaps we should), they shouldn't be shown to the user here because we're showing the same issue multiple times.

### Use case

CLI linting

### Dialect

all

### Are you willing to work on and submit a PR to address the issue?

- [X] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

