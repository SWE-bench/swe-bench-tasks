fix keep adding new line on wrong place 
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

To replicate this issue you can create a file eg. test.template.sql 

```
{% if true %}
SELECT 1 + 1
{%- endif %}
```

then run:
```
sqlfluff fix test.template.sql  
```

This will give you:
```
L:   2 | P:  12 | L009 | Files must end with a trailing newline.
```

And the result of the file is now:
```
{% if true %}
SELECT 1 + 1

{%- endif %}
```

If i run it again it will complain on the same issue and the result of the file would be: 
```
{% if true %}
SELECT 1 + 1


{%- endif %}
```

And so on. 

### Expected Behaviour

The expected behavior would be to add the new line at the end of the file, that is after `{%- endif %}` instead of adding the new line at the end of the SQL query - so the result should look like this: 

```
{% if true %}
SELECT 1 + 1
{%- endif %}

```

### Observed Behaviour

Adds a new line to the end of the SQL query instead of in the end of the file. 

### How to reproduce

Already mentioned above (in What Happened section).

### Dialect

snowflake

### Version

sqlfluff, version 0.6.2

### Configuration

[sqlfluff]
verbose = 1
dialect = snowflake
templater = jinja
exclude_rules = L027,L031,L032,L036,L044,L046,L034
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


[sqlfluff:rules:L010]  # Keywords
capitalisation_policy = upper

[sqlfluff:rules:L014]
extended_capitalisation_policy = lower

[sqlfluff:rules:L030]  # function names
capitalisation_policy = upper

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

