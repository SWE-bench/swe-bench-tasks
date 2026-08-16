BigQuery: Accessing `STRUCT` elements evades triggering L027
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

Accessing unreferenced `STRUCT` elements using BigQuery dot notation in a multi table query does not trigger L027.

### Expected Behaviour

L027 gets triggered.

### Observed Behaviour

L027 does not get triggered.

### How to reproduce

```sql
SELECT
    t1.col1,
    t2.col2,
    events.id
FROM t_table1 AS t1
LEFT JOIN t_table2 AS t2
    ON TRUE
```

### Dialect

BigQUery

### Version

`0.11.2` using online.sqlfluff.com

### Configuration

N/A

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

