L045:  Unused CTEs are not automatically detected when using jinja/dbt as a templater
## Expected Behaviour
When unused CTEs are used with jinja or dbt as a templater, these are detected by L045. 

## Observed Behaviour
When ref() statements are included in a SQL file and dbt is used as a templater, these seem to interfere with the ability for rule L045 to detect the unused CTEs.  The same behavior is observed when Jinja is included under the "FROM" statement of the relevant queries.

## Steps to Reproduce
(1). Generate a valid dbt project with at least two models with one variable each.  For the purposes of this reproduction example, I am going to assume that one model is 'foo' with variable 'var_foo' and one model is 'bar' with variable 'var_bar'.
 
(2) Using DBT as a templater and BigQuery as a dialect, run dbt lint on the following SQL file:

```sql
WITH
random_gibberish AS (
    SELECT var_foo
    FROM
        {{ ref('foo') }}
)

SELECT var_bar
FROM
    {{ ref('bar') }}
```

If the templater is switched to Jinja, L045 again doesn't produce any errors.

## Dialect
Bigquery

## Version
SQLFluff version is 0.10.0.  Python version is 3.8.10.
I'm using dbt 1.0.1 but the same issue occurs when Jinja is used as a templater.

## Configuration
```
[sqlfluff]
dialect = bigquery
exclude_rules = L003,L008,L011,L014,L016,L029,L031,L034

[sqlfluff:rules]
max_line_length = 120
comma_style = leading

[sqlfluff:rules:L010]
capitalisation_policy = upper

[sqlfluff:rules:L030]
capitalisation_policy = upper
```
