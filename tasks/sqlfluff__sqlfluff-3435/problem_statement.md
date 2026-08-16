L027: outer-level table not found in WHERE clause sub-select
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

Outer-level table/view referenced in sub-select inside `WHERE` clause is not being detected.

This error seems to only occur when the sub-select contains joins.

### Expected Behaviour

No error

### Observed Behaviour

```
L:   7 | P:  32 | L027 | Qualified reference 'my_table.kind' not found in
                       | available tables/view aliases ['other_table',
                       | 'mapping_table'] in select with more than one referenced
                       | table/view.
```

### How to reproduce

```sql
SELECT my_col
FROM my_table
WHERE EXISTS (
    SELECT 1
    FROM other_table
    INNER JOIN mapping_table ON (mapping_table.other_fk = other_table.id_pk)
    WHERE mapping_table.kind = my_table.kind
);
```

### Dialect

postgres

### Version

sqlfluff, version 0.12.0

### Configuration

```
[sqlfluff]
nocolor = True
dialect = postgres
```

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

