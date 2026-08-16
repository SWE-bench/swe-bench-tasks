L026: Rule incorrectly flag column does not exist in `FROM` clause in an UPDATE statement.
## Expected Behaviour

L026 should not fail when a subquery in an UPDATE statement references a column from the UPDATE target.

## Observed Behaviour

L026 failed due to reference was not found in the FROM clause with the following error printed (When using `sample.sql` content below)

```
L:   7 | P:  28 | L026 | Reference 'my_table.id' refers to table/view not found
                       | in the FROM clause or found in parent subquery.
```

## Steps to Reproduce

1. Create `sample.sql` with the content below
```
UPDATE my_table
SET row_sum = (
    SELECT COUNT(*) AS row_sum
    FROM
        another_table
    WHERE
        another_table.id = my_table.id
);
```
2. Run SQLFluff by `sqlfluff lint sample.sql`

## Dialect

Default / Ansi (No dialect specified)

## Version
```
(.venv) ~/code/sqlfluff (main) $ sqlfluff --version
sqlfluff, version 0.9.0
```

```
(.venv) ~/code/sqlfluff (main) $ python --version
Python 3.9.9
```

## Configuration
Default. No customization.

