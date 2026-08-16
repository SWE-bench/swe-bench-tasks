Lint and fix throws exception when having jinja for loop inside set
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

To reproduce the error, create test.template.sql
```
{% set whitelisted= [
    {'name': 'COL_1'},
    {'name': 'COL_2'},
    {'name': 'COL_3'}
] %}

{% set some_part_of_the_query %}
    {% for col in whitelisted %}
    {{col.name}}{{ ", " if not loop.last }}
    {% endfor %}
{% endset %}

SELECT {{some_part_of_the_query}}
FROM SOME_TABLE

```

when running lint i get this error:
```
==== sqlfluff ====
sqlfluff:               0.11.0 python:                 3.8.12
implementation:        cpython dialect:             snowflake
verbosity:                   1 templater:               jinja

==== readout ====

=== [ path: test.template.sql ] ===

WARNING    Unable to lint test.template.sql due to an internal error. Please report this as an issue with your query's contents and stacktrace below!
To hide this warning, add the failing file to .sqlfluffignore
Traceback (most recent call last):
  File "lib/python3.8/site-packages/sqlfluff/core/linter/runner.py", line 103, in run
    yield partial()
  File "lib/python3.8/site-packages/sqlfluff/core/linter/linter.py", line 666, in lint_rendered
    parsed = cls.parse_rendered(rendered)
  File "lib/python3.8/site-packages/sqlfluff/core/linter/linter.py", line 352, in parse_rendered
    tokens, lvs, config = cls._lex_templated_file(
  File "lib/python3.8/site-packages/sqlfluff/core/linter/linter.py", line 139, in _lex_templated_file
    tokens, lex_vs = lexer.lex(templated_file)
  File "lib/python3.8/site-packages/sqlfluff/core/parser/lexer.py", line 321, in lex
    segments: Tuple[RawSegment, ...] = self.elements_to_segments(
  File "lib/python3.8/site-packages/sqlfluff/core/parser/lexer.py", line 348, in elements_to_segments
    source_slice = templated_file.templated_slice_to_source_slice(
  File "lib/python3.8/site-packages/sqlfluff/core/templaters/base.py", line 258, in templated_slice_to_source_slice
    ts_stop_sf_start, ts_stop_sf_stop = self._find_slice_indices_of_templated_pos(
  File "lib/python3.8/site-packages/sqlfluff/core/templaters/base.py", line 177, in _find_slice_indices_of_templated_pos
    raise ValueError("Position Not Found")
ValueError: Position Not Found
 
==== summary ====
violations:        0 status:         PASS
All Finished 📜 🎉!

```

This is the rendered query:
```
 SELECT

    COL_1,

    COL_2,

    COL_3


FROM SOME_TABLE

```

And when trying around to make this work i removed the new lines between the selected columns like this:
```
{% set whitelisted= [
    {'name': 'COL_1'},
    {'name': 'COL_2'},
    {'name': 'COL_3'}
] %}

{% set some_part_of_the_query %}
    {% for col in whitelisted -%}
    {{col.name}}{{ ", " if not loop.last }}
    {% endfor -%}
{% endset %}

SELECT {{some_part_of_the_query}}
FROM SOME_TABLE

```

which renders:
```
SELECT
    COL_1,
    COL_2,
    COL_3

FROM SOME_TABLE

```

And this will make the linter pass:

```
==== sqlfluff ====
sqlfluff:               0.11.0 python:                 3.8.12
implementation:        cpython dialect:             snowflake
verbosity:                   1 templater:               jinja

==== readout ====

=== [ path: test.template.sql ] ===

== [test.template.sql] PASS                                                                                                                          
==== summary ====
violations:        0 status:         PASS
All Finished 📜 🎉!

```



### Expected Behaviour

My expectations is that the linter and fix should pass.

### Observed Behaviour

Right now lint and fix throws exception (see "What Happened" section)

### How to reproduce

Mentioned above.

### Dialect

snowflake

### Version

sqlfluff, version 0.11.0

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

