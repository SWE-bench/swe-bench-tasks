noqa is ignored for jinja templated lines
## Expected Behaviour
Line with `noqa: TMP` should be ignored (despite of evaluation error)

## Observed Behaviour
trying to lint airflow sql-template for AWS Athena query
setting up inline `-- noqa` or `--noqa: TMP` for jinja templated line not silenting templating error (typecasting error due to unable to pass datetime object while linting into template context):
```
== [transform/airflow/dags/queries/sfmc/player_balance.sql] FAIL
L:   0 | P:   0 |  TMP | Unrecoverable failure in Jinja templating: unsupported operand type(s) for -: 'int' and 'datetime.timedelta'. Have you configured your variables?
                       | https://docs.sqlfluff.com/en/latest/configuration.html
```

## Steps to Reproduce
templated file:
```sql
select *, row_number() over (partition by player_id order by balance_change_date desc)  as rnk
from raw
where
    balance_change_date >= cast(from_iso8601_timestamp('{{ execution_date - macros.timedelta(hours=2, minutes=10) }}') as timestamp)  and  --noqa: TMP
    balance_change_date < cast(from_iso8601_timestamp('{{ next_execution_date - macros.timedelta(minutes=10) }}') as timestamp) --noqa: TMP
```
run:
```bash
sqlfluff lint transform/airflow/dags/queries/sfmc/player_balance.sql
```

## Dialect
postgres (used for AWS Athena)

## Version
datalake % sqlfluff --version
sqlfluff, version 0.8.1
datalake % python3 --version
Python 3.9.8

## Configuration
```ini
# tox.ini
[sqlfluff]
templater = jinja
output_line_length = 180
exclude_rules = L011,L012,L022,L031,L034
dialect = postgres

[sqlfluff:rules]
max_line_length = 120

[sqlfluff:templater:jinja]
library_path = operation/deploy/lint
apply_dbt_builtins = false

[sqlfluff:templater:jinja:context]
ds = 2021-11-11
ds_nodash = 20211111
start_date = 2021-11-11
end_date = 2021-11-11
interval = 1
# passed as int due to inabliity to pass datetime obkject 
data_interval_start = 1636588800
data_interval_end = 1636588800
```

```python
# operation/deploy/lint/macro.py
from datetime import datetime, timedelta  # noqa: F401

import dateutil  # noqa: F401
```
