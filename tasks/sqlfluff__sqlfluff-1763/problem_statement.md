dbt postgres fix command errors with UnicodeEncodeError and also wipes the .sql file
_If this is a parsing or linting issue, please include a minimal SQL example which reproduces the issue, along with the `sqlfluff parse` output, `sqlfluff lint` output and `sqlfluff fix` output when relevant._

## Expected Behaviour
Violation failure notice at a minimum, without wiping the file. Would like a way to ignore the known error at a minimum as --noqa is not getting past this. Actually would expect --noqa to totally ignore this.

## Observed Behaviour
Reported error: `UnicodeEncodeError: 'charmap' codec can't encode character '\u2192' in position 120: character maps to <undefined>`

## Steps to Reproduce
SQL file:
```sql
SELECT
    reacted_table_name_right.descendant_id AS category_id,
    string_agg(redacted_table_name_left.name, ' → ' ORDER BY reacted_table_name_right.generations DESC) AS breadcrumbs -- noqa
FROM {{ ref2('redacted_schema_name', 'redacted_table_name_left') }} AS redacted_table_name_left
INNER JOIN {{ ref2('redacted_schema_name', 'reacted_table_name_right') }} AS reacted_table_name_right
    ON redacted_table_name_left.id = order_issue_category_hierarchies.ancestor_id
GROUP BY reacted_table_name_right.descendant_id
```
Running `sqlfluff fix --ignore templating,parsing,lexing -vvvv` and accepting proposed fixes for linting violations.

## Dialect
`postgres`, with `dbt` templater

## Version
`python 3.7.12`
`sqlfluff 0.7.0`
`sqlfluff-templater-dbt 0.7.0`

## Configuration
I've tried a few, here's one:
```
[sqlfluff]
verbose = 2
dialect = postgres
templater = dbt
exclude_rules = None
output_line_length = 80
runaway_limit = 10
ignore_templated_areas = True
processes = 3
# Comma separated list of file extensions to lint.

# NB: This config will only apply in the root folder.
sql_file_exts = .sql

[sqlfluff:indentation]
indented_joins = False
indented_using_on = True
template_blocks_indent = True

[sqlfluff:templater]
unwrap_wrapped_queries = True

[sqlfluff:templater:jinja]
apply_dbt_builtins = True

[sqlfluff:templater:jinja:macros]
# Macros provided as builtins for dbt projects
dbt_ref = {% macro ref(model_ref) %}{{model_ref}}{% endmacro %}
dbt_source = {% macro source(source_name, table) %}{{source_name}}_{{table}}{% endmacro %}
dbt_config = {% macro config() %}{% for k in kwargs %}{% endfor %}{% endmacro %}
dbt_var = {% macro var(variable, default='') %}item{% endmacro %}
dbt_is_incremental = {% macro is_incremental() %}True{% endmacro %}

# Common config across rules
[sqlfluff:rules]
tab_space_size = 4
indent_unit = space
single_table_references = consistent
unquoted_identifiers_policy = all

# L001 - Remove trailing whitespace (fix)
# L002 - Single section of whitespace should not contain both tabs and spaces (fix)
# L003 - Keep consistent indentation (fix)
# L004 - We use 4 spaces for indentation just for completeness (fix)
# L005 - Remove space before commas (fix)
# L006 - Operators (+, -, *, /) will be wrapped by a single space each side (fix)

# L007 - Operators should not be at the end of a line
[sqlfluff:rules:L007]  # Keywords
operator_new_lines = after

# L008 - Always use a single whitespace after a comma (fix)
# L009 - Files will always end with a trailing newline

# L010 - All keywords will use full upper case (fix)
[sqlfluff:rules:L010]  # Keywords
capitalisation_policy = upper

# L011 - Always explicitly alias tables (fix)
[sqlfluff:rules:L011]  # Aliasing
aliasing = explicit

# L012 - Do not have to explicitly alias all columns
[sqlfluff:rules:L012]  # Aliasing
aliasing = explicit

# L013 - Always explicitly alias a column with an expression in it (fix)
[sqlfluff:rules:L013]  # Aliasing
allow_scalar = False

# L014 - Always user full lower case for 'quoted identifiers' -> column refs. without an alias (fix)
[sqlfluff:rules:L014]  # Unquoted identifiers
extended_capitalisation_policy = lower

# L015 - Always remove parenthesis when using DISTINCT to be clear that DISTINCT applies to all columns (fix)

# L016 - Lines should be 120 characters of less. Comment lines should not be ignored (fix)
[sqlfluff:rules:L016]
ignore_comment_lines = False
max_line_length = 120

# L017 - There should not be whitespace between function name and brackets (fix)
# L018 - Always align closing bracket of WITH to the WITH keyword (fix)

# L019 - Always use trailing commas / commas at the end of the line (fix)
[sqlfluff:rules:L019]
comma_style = trailing

# L020 - Table aliases will always be unique per statement
# L021 - Remove any use of ambiguous DISTINCT and GROUP BY combinations. Lean on removing the GROUP BY.
# L022 - Add blank lines after common table expressions (CTE) / WITH.
# L023 - Always add a single whitespace after AS in a WITH clause (fix)

[sqlfluff:rules:L026]
force_enable = False

# L027 - Always add references if more than one referenced table or view is used

[sqlfluff:rules:L028]
force_enable = False

[sqlfluff:rules:L029]  # Keyword identifiers
unquoted_identifiers_policy = aliases

[sqlfluff:rules:L030]  # Function names
capitalisation_policy = upper

# L032 - We prefer use of join keys rather than USING
# L034 - We prefer ordering of columns in select statements as (fix):
# 1. wildcards
# 2. single identifiers
# 3. calculations and aggregates

# L035 - Omit 'else NULL'; it is redundant (fix)
# L036 - Move select targets / identifiers onto new lines each (fix)
# L037 - When using ORDER BY, make the direction explicit (fix)

# L038 - Never use trailing commas at the end of the SELECT clause
[sqlfluff:rules:L038]
select_clause_trailing_comma = forbid

# L039 - Remove unnecessary whitespace (fix)

[sqlfluff:rules:L040]  # Null & Boolean Literals
capitalisation_policy = upper

# L042 - Join clauses should not contain subqueries. Use common tables expressions (CTE) instead.
[sqlfluff:rules:L042]
# By default, allow subqueries in from clauses, but not join clauses.
forbid_subquery_in = join

# L043 - Reduce CASE WHEN conditions to COALESCE (fix)
# L044 - Prefer a known number of columns along the path to the source data
# L045 - Remove unused common tables expressions (CTE) / WITH statements (fix)
# L046 - Jinja tags should have a single whitespace on both sides

# L047 - Use COUNT(*) instead of COUNT(0) or COUNT(1) alternatives (fix)
[sqlfluff:rules:L047]  # Consistent syntax to count all rows
prefer_count_1 = False
prefer_count_0 = False

# L048 - Quoted literals should be surrounded by a single whitespace (fix)
# L049 - Always use IS or IS NOT for comparisons with NULL (fix)
```

