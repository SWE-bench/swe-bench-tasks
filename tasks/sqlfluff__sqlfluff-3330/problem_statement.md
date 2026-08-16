Rule suggestion: `UNION [ALL|DISTINCT]` on new line
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### Description

I would like to suggest a new rule that puts `UNION [ALL|DISTINCT]` statements on their own line, aligned to the surrounding `SELECT` statements.

For example, currently 

```sql
SELECT 1 UNION ALL
SELECT 2
```

passes without errors. This new rule could fix that to

```sql
SELECT 1 
UNION ALL
SELECT 2
```

Or in a more complex example

```sql
SELECT * FROM (
    SELECT 1 UNION ALL
    SELECT 2
)
```

fixed to

```sql
SELECT * FROM (
    SELECT 1 
    UNION ALL
    SELECT 2
)
```

### Use case

I have looked at a few SQL style guides and they don't really seem to mention any policy regarding `UNION` statements. However, in 99% of the SQL I have encountered `UNION` statements always seemed to be on a new line. It would be great to have an option to lint the remaining 1% 😉 

### Dialect

ansi

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

