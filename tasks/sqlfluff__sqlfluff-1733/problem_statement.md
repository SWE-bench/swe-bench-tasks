Extra space when first field moved to new line in a WITH statement
Note, the query below uses a `WITH` statement. If I just try to fix the SQL within the CTE, this works fine.

Given the following SQL:

```sql
WITH example AS (
    SELECT my_id,
        other_thing,
        one_more
    FROM
        my_table
)

SELECT *
FROM example
```

## Expected Behaviour

after running `sqlfluff fix` I'd expect (`my_id` gets moved down and indented properly):

```sql
WITH example AS (
    SELECT
        my_id,
        other_thing,
        one_more
    FROM
        my_table
)

SELECT *
FROM example
```

## Observed Behaviour

after running `sqlfluff fix` we get (notice that `my_id` is indented one extra space)

```sql
WITH example AS (
    SELECT
         my_id,
        other_thing,
        one_more
    FROM
        my_table
)

SELECT *
FROM example
```

## Steps to Reproduce

Noted above. Create a file with the initial SQL and fun `sqfluff fix` on it.

## Dialect

Running with default config.

## Version
Include the output of `sqlfluff --version` along with your Python version

sqlfluff, version 0.7.0
Python 3.7.5

## Configuration

Default config.

