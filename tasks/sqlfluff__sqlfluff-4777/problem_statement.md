`fix` per file linted instead of at the end
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### Description

I am just testing sqlfluff on a small example project.
We have configured it as part of `pre-commit`.

```
-   repo: https://github.com/sqlfluff/sqlfluff
    rev: 1.0.0
    hooks:
    -   id: sqlfluff-fix
        args: [--config, ".sqlfluff", --disable_progress_bar, --processes, "2", --bench]
        files: \.(sql)$
        exclude: sp_whoisactive.sql
```

Processing our example already takes 30 minutes, I thus think formatting any real project would take 4+ hours.

At the moment the files are all formated first and _all together_ written at the very end. I see no benefit in writing at the very end, why are they not written sequentially?

### Use case

Instead of writing all formatted sql at the end, I would like to see files written sequentially.

### Dialect

most likely all, i am working with t-sql.

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

`fix` per file linted instead of at the end
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### Description

I am just testing sqlfluff on a small example project.
We have configured it as part of `pre-commit`.

```
-   repo: https://github.com/sqlfluff/sqlfluff
    rev: 1.0.0
    hooks:
    -   id: sqlfluff-fix
        args: [--config, ".sqlfluff", --disable_progress_bar, --processes, "2", --bench]
        files: \.(sql)$
        exclude: sp_whoisactive.sql
```

Processing our example already takes 30 minutes, I thus think formatting any real project would take 4+ hours.

At the moment the files are all formated first and _all together_ written at the very end. I see no benefit in writing at the very end, why are they not written sequentially?

### Use case

Instead of writing all formatted sql at the end, I would like to see files written sequentially.

### Dialect

most likely all, i am working with t-sql.

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

