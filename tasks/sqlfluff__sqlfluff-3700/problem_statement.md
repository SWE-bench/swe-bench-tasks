L042 loop limit on fixes reached when CTE itself contains a subquery
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

While running `sqlfluff fix --dialect snowflake` on a sql file, I get 
```
==== finding fixable violations ====
WARNING    Loop limit on fixes reached [10].                                                                                                                                                              
==== no fixable linting violations found ====                                                                                                                                                             
All Finished 📜 🎉!
  [22 unfixable linting violations found]
```

```
INSERT OVERWRITE INTO dwh.test_table

WITH cte1 AS (
	SELECT *
	FROM (SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY r ORDER BY updated_at DESC) AS latest
		FROM mongo.temp
	WHERE latest = 1
))

SELECT * FROM cte1 WHERE 1=1;
```

All of the 22  violations are a mix of L002, L003 and L004.

### Expected Behaviour

`sqlfluff` should be able to fix the violations

### Observed Behaviour

Even if I try to fix the violations manually, it still shows the same error.

### How to reproduce

I will try to generate a sql file that will be able to reproduce the issue

### Dialect

Snowflake

### Version

1.1.0

### Configuration

```
# https://docs.sqlfluff.com/en/stable/rules.html

[sqlfluff]
exclude_rules = L029, L031, L034

[sqlfluff:indentation]
indented_joins = true
indented_using_on = true

[sqlfluff:rules:L002]
tab_space_size = 4

[sqlfluff:rules:L003]
hanging_indents = true
indent_unit = tab
tab_space_size = 4

[sqlfluff:rules:L004]
indent_unit = tab
tab_space_size = 4

[sqlfluff:rules:L010]
capitalisation_policy = upper

[sqlfluff:rules:L011]
aliasing = explicit

[sqlfluff:rules:L012]
aliasing = explicit

[sqlfluff:rules:L014]
extended_capitalisation_policy = lower

[sqlfluff:rules:L016]
ignore_comment_clauses = true
ignore_comment_lines = true
indent_unit = tab
tab_space_size = 4

[sqlfluff:rules:L019]
comma_style = trailing

[sqlfluff:rules:L022]
comma_style = trailing

[sqlfluff:rules:L028]
single_table_references = unqualified

[sqlfluff:rules:L030]
extended_capitalisation_policy = upper

[sqlfluff:rules:L040]
capitalisation_policy = upper

[sqlfluff:rules:L042]
forbid_subquery_in = both

[sqlfluff:rules:L054]
group_by_and_order_by_style = explicit

[sqlfluff:rules:L063]
extended_capitalisation_policy = upper

[sqlfluff:rules:L066]
min_alias_length = 3
max_alias_length = 15

[sqlfluff:templater:jinja:context]
params = {"DB": "DEMO"}
```

### Are you willing to work on and submit a PR to address the issue?

- [X] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

