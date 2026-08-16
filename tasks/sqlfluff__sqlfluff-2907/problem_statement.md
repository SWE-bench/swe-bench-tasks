sqlfluff doesn't recognise a jinja variable set inside of "if" statement
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

When I try to define a jinja variable using "set" jinja directive inside of an "if" jinja statement, sqlfluff complains: 
"Undefined jinja template variable".

### Expected Behaviour

to not have a linting issue

### Observed Behaviour

sqlfluff lint gives an error:
"Undefined jinja template variable"

### How to reproduce

try to create a "temp.sql" file with the following content

```
{% if True %}
    {% set some_var %}1{% endset %}
    SELECT {{some_var}}
{% endif %}
```

and run:
```
sqlfluff lint ./temp.sql
```

You will get the following error:
```
== [./temp.sql] FAIL                                                                                                                    
L:   2 | P:  12 |  TMP | Undefined jinja template variable: 'some_var'
L:   3 | P:  14 |  TMP | Undefined jinja template variable: 'some_var'
```

### Dialect

tested on 'snowflake' dialect

### Version

sqlfluff, version 0.11.1
Python 3.8.12

### Configuration

[sqlfluff]
verbose = 1
dialect = snowflake
templater = jinja
exclude_rules = L027,L031,L032,L036,L044,L046,L034,L050
output_line_length = 121
sql_file_exts=.sql

[sqlfluff:rules]
tab_space_size = 4
max_line_length = 250
indent_unit = space
comma_style = trailing
allow_scalar = True
single_table_references = consistent
unquoted_identifiers_policy = aliases

[sqlfluff:rules:L042]
forbid_subquery_in = both

[sqlfluff:rules:L010]  # Keywords
capitalisation_policy = upper

[sqlfluff:rules:L014]
extended_capitalisation_policy = lower

[sqlfluff:rules:L030]  # function names
extended_capitalisation_policy = upper

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

