Exception thrown when SELECT DISTINCT not on the same line
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

Check a file containing this request:

```sql
SELECT
    DISTINCT `FIELD`
FROM `TABLE`;
```

It fails this way:

```log
CRITICAL   [RF01] Applying rule RF01 to 'file.sql' threw an Exception:  
Traceback (most recent call last):
  File "/app/.venv/lib/python3.9/site-packages/sqlfluff/core/rules/base.py", line 864, in crawl
    res = self._eval(context=context)
  File "/app/.venv/lib/python3.9/site-packages/sqlfluff/rules/references/RF01.py", line 107, in _eval
    self._analyze_table_references(
  File "/app/.venv/lib/python3.9/site-packages/sqlfluff/rules/references/RF01.py", line 152, in _analyze_table_references
    if not self._should_ignore_reference(r, selectable):
  File "/app/.venv/lib/python3.9/site-packages/sqlfluff/rules/references/RF01.py", line 168, in _should_ignore_reference
    ref_path = selectable.selectable.path_to(reference)
  File "/app/.venv/lib/python3.9/site-packages/sqlfluff/core/parser/segments/base.py", line 1184, in path_to
    elif not self.get_start_loc() <= midpoint.get_start_loc() <= self.get_end_loc():
  File "/app/.venv/lib/python3.9/site-packages/sqlfluff/core/parser/segments/base.py", line 877, in get_start_loc
    assert self.pos_marker
AssertionError
== [file.sql] FAIL
L:   1 | P:   1 | LT09 | Select targets should be on a new line unless there is
                       | only one select target. [layout.select_targets]
L:   1 | P:   1 | LT10 | 'SELECT' modifiers (e.g. 'DISTINCT') must be on the same
                       | line as 'SELECT'. [layout.select_modifiers]
L:   1 | P:   1 | RF01 | Unexpected exception: ;
Could you open an issue at
                       | https://github.com/sqlfluff/sqlfluff/issues ?
You can
                       | ignore this exception for now, by adding '-- noqa: RF01'
                       | at the end
of line 1
 [references.from]
L:   2 | P:   1 | LT02 | Line should not be indented. [layout.indent]
L:   3 | P:  13 | LT12 | Files must end with a single trailing newline.
                       | [layout.end_of_file]
All Finished!
```

Checking the following request does not throw an exception (move `DISTINCT` on same line than `SELECT`):

```sql
SELECT DISTINCT `FIELD`
FROM `TABLE`;
```

Additionally, I'd like to add that checking the first request on https://online.sqlfluff.com/fluffed leads to the same exception. But if you check this request:
```sql
SELECT 
DISTINCT
`FIELD`
FROM `TABLE`;
```
Then the website crashes.

### Expected Behaviour

I would expect not to have an exception.

### Observed Behaviour

An exception was thrown whereas, I think, there is no reason to throw it.

### How to reproduce

Check the following SQL:

```sql
SELECT
    DISTINCT `FIELD`
FROM `TABLE`;
```

### Dialect

MySQL

### Version

2.3.2

### Configuration

```
[sqlfluff]
# Supported dialects https://docs.sqlfluff.com/en/stable/dialects.html
dialect = mysql
encoding = utf-8
# Exclude rule LT01/layout.spacing: it expects a space even after type of fields (i.e. "INT (11)")
# Exclude rule ST05/structure.subquery: MySQL badly supports CTEs.
exclude_rules = LT01, ST05
ignore = parsing
max_line_length = 120
# Below controls SQLFluff output, see max_line_length for SQL output
output_line_length = 80
templater = raw
verbose = 0

[sqlfluff:layout:type:binary_operator]
line_position = leading

[sqlfluff:layout:type:comma]
line_position = trailing
spacing_before = touch

[sqlfluff:indentation]
# See https://docs.sqlfluff.com/en/stable/indentation.html
indent_unit = space
indented_joins = True
indented_using_on = True
tab_space_size = 4

# Some rules can be configured directly from the config common to other rules
[sqlfluff:rules]
allow_scalar = True
quoted_identifiers_policy = none
single_table_references = consistent
unquoted_identifiers_policy = all

[sqlfluff:rules:aliasing.column]
aliasing = explicit

[sqlfluff:rules:aliasing.table]
aliasing = explicit

[sqlfluff:rules:ambiguous.column_references]
group_by_and_order_by_style = consistent

[sqlfluff:rules:capitalisation.functions]
capitalisation_policy = upper
ignore_words = None

[sqlfluff:rules:capitalisation.identifiers]
extended_capitalisation_policy = upper
ignore_words = None

[sqlfluff:rules:capitalisation.keywords]
capitalisation_policy = upper
ignore_words = None

[sqlfluff:rules:capitalisation.literals]
capitalisation_policy = upper
ignore_words = None

[sqlfluff:rules:capitalisation.types]
extended_capitalisation_policy = upper

[sqlfluff:rules:convention.count_rows]
prefer_count_0 = False
prefer_count_1 = True

[sqlfluff:rules:convention.select_trailing_comma]
select_clause_trailing_comma = forbid

[sqlfluff:rules:convention.terminator]
multiline_newline = False
require_final_semicolon = True

[sqlfluff:rules:layout.long_lines]
ignore_comment_lines = True

[sqlfluff:rules:references.keywords]
ignore_words = None
quoted_identifiers_policy = none
unquoted_identifiers_policy = all

[sqlfluff:rules:convention.quoted_literals]
preferred_quoted_literal_style = single_quotes

[sqlfluff:rules:references.quoting]
prefer_quoted_identifiers = True

[sqlfluff:rules:references.special_chars]
additional_allowed_characters = ""
allow_space_in_identifier = False
quoted_identifiers_policy = all
# Special characters in identifiers
unquoted_identifiers_policy = all
```

### Are you willing to work on and submit a PR to address the issue?

- [X] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

Exception thrown when SELECT DISTINCT not on the same line
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

Check a file containing this request:

```sql
SELECT
    DISTINCT `FIELD`
FROM `TABLE`;
```

It fails this way:

```log
CRITICAL   [RF01] Applying rule RF01 to 'file.sql' threw an Exception:  
Traceback (most recent call last):
  File "/app/.venv/lib/python3.9/site-packages/sqlfluff/core/rules/base.py", line 864, in crawl
    res = self._eval(context=context)
  File "/app/.venv/lib/python3.9/site-packages/sqlfluff/rules/references/RF01.py", line 107, in _eval
    self._analyze_table_references(
  File "/app/.venv/lib/python3.9/site-packages/sqlfluff/rules/references/RF01.py", line 152, in _analyze_table_references
    if not self._should_ignore_reference(r, selectable):
  File "/app/.venv/lib/python3.9/site-packages/sqlfluff/rules/references/RF01.py", line 168, in _should_ignore_reference
    ref_path = selectable.selectable.path_to(reference)
  File "/app/.venv/lib/python3.9/site-packages/sqlfluff/core/parser/segments/base.py", line 1184, in path_to
    elif not self.get_start_loc() <= midpoint.get_start_loc() <= self.get_end_loc():
  File "/app/.venv/lib/python3.9/site-packages/sqlfluff/core/parser/segments/base.py", line 877, in get_start_loc
    assert self.pos_marker
AssertionError
== [file.sql] FAIL
L:   1 | P:   1 | LT09 | Select targets should be on a new line unless there is
                       | only one select target. [layout.select_targets]
L:   1 | P:   1 | LT10 | 'SELECT' modifiers (e.g. 'DISTINCT') must be on the same
                       | line as 'SELECT'. [layout.select_modifiers]
L:   1 | P:   1 | RF01 | Unexpected exception: ;
Could you open an issue at
                       | https://github.com/sqlfluff/sqlfluff/issues ?
You can
                       | ignore this exception for now, by adding '-- noqa: RF01'
                       | at the end
of line 1
 [references.from]
L:   2 | P:   1 | LT02 | Line should not be indented. [layout.indent]
L:   3 | P:  13 | LT12 | Files must end with a single trailing newline.
                       | [layout.end_of_file]
All Finished!
```

Checking the following request does not throw an exception (move `DISTINCT` on same line than `SELECT`):

```sql
SELECT DISTINCT `FIELD`
FROM `TABLE`;
```

Additionally, I'd like to add that checking the first request on https://online.sqlfluff.com/fluffed leads to the same exception. But if you check this request:
```sql
SELECT 
DISTINCT
`FIELD`
FROM `TABLE`;
```
Then the website crashes.

### Expected Behaviour

I would expect not to have an exception.

### Observed Behaviour

An exception was thrown whereas, I think, there is no reason to throw it.

### How to reproduce

Check the following SQL:

```sql
SELECT
    DISTINCT `FIELD`
FROM `TABLE`;
```

### Dialect

MySQL

### Version

2.3.2

### Configuration

```
[sqlfluff]
# Supported dialects https://docs.sqlfluff.com/en/stable/dialects.html
dialect = mysql
encoding = utf-8
# Exclude rule LT01/layout.spacing: it expects a space even after type of fields (i.e. "INT (11)")
# Exclude rule ST05/structure.subquery: MySQL badly supports CTEs.
exclude_rules = LT01, ST05
ignore = parsing
max_line_length = 120
# Below controls SQLFluff output, see max_line_length for SQL output
output_line_length = 80
templater = raw
verbose = 0

[sqlfluff:layout:type:binary_operator]
line_position = leading

[sqlfluff:layout:type:comma]
line_position = trailing
spacing_before = touch

[sqlfluff:indentation]
# See https://docs.sqlfluff.com/en/stable/indentation.html
indent_unit = space
indented_joins = True
indented_using_on = True
tab_space_size = 4

# Some rules can be configured directly from the config common to other rules
[sqlfluff:rules]
allow_scalar = True
quoted_identifiers_policy = none
single_table_references = consistent
unquoted_identifiers_policy = all

[sqlfluff:rules:aliasing.column]
aliasing = explicit

[sqlfluff:rules:aliasing.table]
aliasing = explicit

[sqlfluff:rules:ambiguous.column_references]
group_by_and_order_by_style = consistent

[sqlfluff:rules:capitalisation.functions]
capitalisation_policy = upper
ignore_words = None

[sqlfluff:rules:capitalisation.identifiers]
extended_capitalisation_policy = upper
ignore_words = None

[sqlfluff:rules:capitalisation.keywords]
capitalisation_policy = upper
ignore_words = None

[sqlfluff:rules:capitalisation.literals]
capitalisation_policy = upper
ignore_words = None

[sqlfluff:rules:capitalisation.types]
extended_capitalisation_policy = upper

[sqlfluff:rules:convention.count_rows]
prefer_count_0 = False
prefer_count_1 = True

[sqlfluff:rules:convention.select_trailing_comma]
select_clause_trailing_comma = forbid

[sqlfluff:rules:convention.terminator]
multiline_newline = False
require_final_semicolon = True

[sqlfluff:rules:layout.long_lines]
ignore_comment_lines = True

[sqlfluff:rules:references.keywords]
ignore_words = None
quoted_identifiers_policy = none
unquoted_identifiers_policy = all

[sqlfluff:rules:convention.quoted_literals]
preferred_quoted_literal_style = single_quotes

[sqlfluff:rules:references.quoting]
prefer_quoted_identifiers = True

[sqlfluff:rules:references.special_chars]
additional_allowed_characters = ""
allow_space_in_identifier = False
quoted_identifiers_policy = all
# Special characters in identifiers
unquoted_identifiers_policy = all
```

### Are you willing to work on and submit a PR to address the issue?

- [X] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

