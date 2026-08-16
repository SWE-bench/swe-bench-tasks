dbt & JinjaTracer results in passing invalid query to database (was: DBT Call statement() block causes invalid query generated)
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

When using the call statement() to run a query during compile time, the query generated is garbled causing the following sql error:
```
{% call statement('variables', fetch_result=true) %}

select 1 as test;

{% endcall %}

{% set test = load_result('variables')['table'].columns.TEST.values()[0] %}
```

This results in the following error:

dbt.exceptions.DatabaseException: Database Error
  001003 (42000): SQL compilation error:
  syntax error line 1 at position 0 unexpected '0'.

The query ran looks like this when looking at the query runner history in snowflake:

```
☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺_0☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺_8☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺☺_0
```

Whereas it should show:
```
select 1 as test;
```

### Expected Behaviour

Expected that the query runs properly.

### Observed Behaviour

```
=== [dbt templater] Compiling dbt project...
=== [dbt templater] Project Compiled.
Traceback (most recent call last):
  File "/usr/local/lib/python3.9/site-packages/dbt/adapters/snowflake/connections.py", line 219, in exception_handler
    yield
  File "/usr/local/lib/python3.9/site-packages/dbt/adapters/sql/connections.py", line 70, in add_query
    cursor.execute(sql, bindings)
  File "/usr/local/lib/python3.9/site-packages/snowflake/connector/cursor.py", line 794, in execute
    Error.errorhandler_wrapper(self.connection, self, error_class, errvalue)
  File "/usr/local/lib/python3.9/site-packages/snowflake/connector/errors.py", line 273, in errorhandler_wrapper
    handed_over = Error.hand_to_other_handler(
  File "/usr/local/lib/python3.9/site-packages/snowflake/connector/errors.py", line 328, in hand_to_other_handler
    cursor.errorhandler(connection, cursor, error_class, error_value)
  File "/usr/local/lib/python3.9/site-packages/snowflake/connector/errors.py", line 207, in default_errorhandler
    raise error_class(
snowflake.connector.errors.ProgrammingError: 001003 (42000): SQL compilation error:
syntax error line 1 at position 0 unexpected '0'.

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/usr/local/bin/sqlfluff", line 8, in <module>
    sys.exit(cli())
  File "/usr/local/lib/python3.9/site-packages/click/core.py", line 1130, in __call__
    return self.main(*args, **kwargs)
  File "/usr/local/lib/python3.9/site-packages/click/core.py", line 1055, in main
    rv = self.invoke(ctx)
  File "/usr/local/lib/python3.9/site-packages/click/core.py", line 1657, in invoke
    return _process_result(sub_ctx.command.invoke(sub_ctx))
  File "/usr/local/lib/python3.9/site-packages/click/core.py", line 1404, in invoke
    return ctx.invoke(self.callback, **ctx.params)
  File "/usr/local/lib/python3.9/site-packages/click/core.py", line 760, in invoke
    return __callback(*args, **kwargs)
  File "/usr/local/lib/python3.9/site-packages/sqlfluff/cli/commands.py", line 1008, in parse
    parsed_strings = list(
  File "/usr/local/lib/python3.9/site-packages/sqlfluff/core/linter/linter.py", line 1171, in parse_path
    yield self.parse_string(
  File "/usr/local/lib/python3.9/site-packages/sqlfluff/core/linter/linter.py", line 835, in parse_string
    rendered = self.render_string(in_str, fname, config, encoding)
  File "/usr/local/lib/python3.9/site-packages/sqlfluff/core/linter/linter.py", line 784, in render_string
    templated_file, templater_violations = self.templater.process(
  File "/usr/local/lib/python3.9/site-packages/sqlfluff/core/templaters/base.py", line 47, in _wrapped
    return func(self, in_str=in_str, fname=fname, config=config, **kwargs)
  File "/usr/local/lib/python3.9/site-packages/sqlfluff_templater_dbt/templater.py", line 331, in process
    processed_result = self._unsafe_process(fname_absolute_path, in_str, config)
  File "/usr/local/lib/python3.9/site-packages/sqlfluff_templater_dbt/templater.py", line 552, in _unsafe_process
    raw_sliced, sliced_file, templated_sql = self.slice_file(
  File "/usr/local/lib/python3.9/site-packages/sqlfluff/core/templaters/jinja.py", line 462, in slice_file
    trace = tracer.trace(append_to_templated=kwargs.pop("append_to_templated", ""))
  File "/usr/local/lib/python3.9/site-packages/sqlfluff/core/templaters/slicers/tracer.py", line 77, in trace
    trace_template_output = trace_template.render()
  File "/usr/local/lib/python3.9/site-packages/jinja2/environment.py", line 1090, in render
    self.environment.handle_exception()
  File "/usr/local/lib/python3.9/site-packages/jinja2/environment.py", line 832, in handle_exception
    reraise(*rewrite_traceback_stack(source=source))
  File "/usr/local/lib/python3.9/site-packages/jinja2/_compat.py", line 28, in reraise
    raise value.with_traceback(tb)
  File "<template>", line 16, in top-level template code
  File "/usr/local/lib/python3.9/site-packages/jinja2/sandbox.py", line 462, in call
    return __context.call(__obj, *args, **kwargs)
  File "/usr/local/lib/python3.9/site-packages/dbt/clients/jinja.py", line 321, in __call__
    return self.call_macro(*args, **kwargs)
  File "/usr/local/lib/python3.9/site-packages/dbt/clients/jinja.py", line 248, in call_macro
    return macro(*args, **kwargs)
  File "/usr/local/lib/python3.9/site-packages/jinja2/runtime.py", line 679, in _invoke
    rv = self._func(*arguments)
  File "<template>", line 10, in template
  File "/usr/local/lib/python3.9/site-packages/jinja2/sandbox.py", line 462, in call
    return __context.call(__obj, *args, **kwargs)
  File "/usr/local/lib/python3.9/site-packages/dbt/adapters/base/impl.py", line 235, in execute
    return self.connections.execute(sql=sql, auto_begin=auto_begin, fetch=fetch)
  File "/usr/local/lib/python3.9/site-packages/dbt/adapters/sql/connections.py", line 122, in execute
    _, cursor = self.add_query(sql, auto_begin)
  File "/usr/local/lib/python3.9/site-packages/dbt/adapters/snowflake/connections.py", line 458, in add_query
    connection, cursor = super().add_query(
  File "/usr/local/lib/python3.9/site-packages/dbt/adapters/sql/connections.py", line 78, in add_query
    return connection, cursor
  File "/usr/local/Cellar/python@3.9/3.9.13_1/Frameworks/Python.framework/Versions/3.9/lib/python3.9/contextlib.py", line 137, in __exit__
    self.gen.throw(typ, value, traceback)
  File "/usr/local/lib/python3.9/site-packages/dbt/adapters/snowflake/connections.py", line 238, in exception_handler
    raise DatabaseException(msg)
dbt.exceptions.DatabaseException: Database Error
  001003 (42000): SQL compilation error:
  syntax error line 1 at position 0 unexpected '0'.
```

### How to reproduce

Use the statement() block described here:
https://docs.getdbt.com/reference/dbt-jinja-functions/statement-blocks



### Dialect

Snowflake

### Version

1.2.0 with the dbt formatter

### Configuration

```
[sqlfluff]
# verbose is an integer (0-2) indicating the level of log output
verbose = 2
# Turn off color formatting of output
nocolor = False
# Supported dialects https://docs.sqlfluff.com/en/stable/dialects.html
# Or run 'sqlfluff dialects'
dialect = snowflake
# One of [raw|jinja|python|placeholder]
templater = dbt
# Comma separated list of rules to check, default to all
rules = all
# Comma separated list of rules to exclude, or None
exclude_rules = None
# The depth to recursively parse to (0 for unlimited)
recurse = 0
# Below controls SQLFluff output, see max_line_length for SQL output
output_line_length = 80
# Number of passes to run before admitting defeat
runaway_limit = 10
# Ignore errors by category (one or more of the following, separated by commas: lexing,linting,parsing,templating)
ignore = None
# Ignore linting errors found within sections of code coming directly from
# templated code (e.g. from within Jinja curly braces. Note that it does not
# ignore errors from literal code found within template loops.
ignore_templated_areas = True
# can either be autodetect or a valid encoding e.g. utf-8, utf-8-sig
encoding = autodetect
# Ignore inline overrides (e.g. to test if still required)
disable_noqa = False
# Comma separated list of file extensions to lint
# NB: This config will only apply in the root folder
sql_file_exts = .sql,.sql.j2,.dml,.ddl
# Allow fix to run on files, even if they contain parsing errors
# Note altering this is NOT RECOMMENDED as can corrupt SQL
fix_even_unparsable = False
# Very large files can make the parser effectively hang.
# This limit skips files over a certain character length
# and warns the user what has happened.
# Set this to 0 to disable.
large_file_skip_char_limit = 20000

[sqlfluff:indentation]
# See https://docs.sqlfluff.com/en/stable/indentation.html
indented_joins = False
indented_ctes = False
indented_using_on = True
indented_on_contents = True
template_blocks_indent = True

[sqlfluff:templater]
unwrap_wrapped_queries = True

[sqlfluff:templater:jinja]
apply_dbt_builtins = True
load_macros_from_path = macros/

[sqlfluff:templater:jinja:macros]
# Macros provided as builtins for dbt projects
dbt_ref = {% macro ref(model_ref) %}{{model_ref}}{% endmacro %}
dbt_source = {% macro source(source_name, table) %}{{source_name}}_{{table}}{% endmacro %}
dbt_config = {% macro config() %}{% for k in kwargs %}{% endfor %}{% endmacro %}
dbt_var = {% macro var(variable, default='') %}item{% endmacro %}
dbt_is_incremental = {% macro is_incremental() %}True{% endmacro %}

[sqlfluff:templater:dbt]
project_dir = ./

# Some rules can be configured directly from the config common to other rules
[sqlfluff:rules]
tab_space_size = 4
max_line_length = 120
indent_unit = space
comma_style = trailing
allow_scalar = True
single_table_references = consistent
unquoted_identifiers_policy = all

# Some rules have their own specific config
[sqlfluff:rules:L003]
hanging_indents = True

[sqlfluff:rules:L007]
operator_new_lines = after

[sqlfluff:rules:L010]
# Keywords
capitalisation_policy = lower
# Comma separated list of words to ignore for this rule
ignore_words = None
ignore_words_regex = None

[sqlfluff:rules:L011]
# Aliasing preference for tables
aliasing = explicit

[sqlfluff:rules:L012]
# Aliasing preference for columns
aliasing = explicit

[sqlfluff:rules:L014]
# Unquoted identifiers
extended_capitalisation_policy = lower
# Comma separated list of words to ignore for this rule
ignore_words = None
ignore_words_regex = None

[sqlfluff:rules:L016]
# Line length
ignore_comment_lines = False
ignore_comment_clauses = False

[sqlfluff:rules:L027]
# Comma separated list of words to ignore for this rule
ignore_words = None
ignore_words_regex = None

[sqlfluff:rules:L026]
# References must be in FROM clause
# Disabled for some dialects (e.g. bigquery)
force_enable = False

[sqlfluff:rules:L028]
# References must be consistently used
# Disabled for some dialects (e.g. bigquery)
force_enable = False

[sqlfluff:rules:L029]
# Keywords should not be used as identifiers.
unquoted_identifiers_policy = aliases
quoted_identifiers_policy = none
# Comma separated list of words to ignore for this rule
ignore_words = None
ignore_words_regex = None

[sqlfluff:rules:L030]
# Function names
extended_capitalisation_policy = lower
# Comma separated list of words to ignore for this rule
ignore_words = None
ignore_words_regex = None

[sqlfluff:rules:L031]
# Avoid table aliases in from clauses and join conditions.
# Disabled for some dialects (e.g. bigquery)
force_enable = False

[sqlfluff:rules:L036]
wildcard_policy = single

[sqlfluff:rules:L038]
# Trailing commas
select_clause_trailing_comma = forbid

[sqlfluff:rules:L040]
# Null & Boolean Literals
capitalisation_policy = consistent
# Comma separated list of words to ignore for this rule
ignore_words = None
ignore_words_regex = None

[sqlfluff:rules:L042]
# By default, allow subqueries in from clauses, but not join clauses
forbid_subquery_in = join

[sqlfluff:rules:L047]
# Consistent syntax to count all rows
prefer_count_1 = False
prefer_count_0 = False

[sqlfluff:rules:L051]
# Fully qualify JOIN clause
fully_qualify_join_types = inner

[sqlfluff:rules:L052]
# Semi-colon formatting approach
multiline_newline = False
require_final_semicolon = False

[sqlfluff:rules:L054]
# GROUP BY/ORDER BY column references
group_by_and_order_by_style = consistent

[sqlfluff:rules:L057]
# Special characters in identifiers
unquoted_identifiers_policy = all
quoted_identifiers_policy = all
allow_space_in_identifier = False
additional_allowed_characters = ""
ignore_words = None
ignore_words_regex = None

[sqlfluff:rules:L059]
# Policy on quoted and unquoted identifiers
prefer_quoted_identifiers = False
ignore_words = None
ignore_words_regex = None
force_enable = False

[sqlfluff:rules:L062]
# Comma separated list of blocked words that should not be used
blocked_words = None
blocked_regex = None

[sqlfluff:rules:L063]
# Data Types
extended_capitalisation_policy = consistent
# Comma separated list of words to ignore for this rule
ignore_words = None
ignore_words_regex = None

[sqlfluff:rules:L064]
# Consistent usage of preferred quotes for quoted literals
preferred_quoted_literal_style = consistent
# Disabled for dialects that do not support single and double quotes for quoted literals (e.g. Postgres)
force_enable = False

[sqlfluff:rules:L066]
min_alias_length = None
max_alias_length = None
```

### Are you willing to work on and submit a PR to address the issue?

- [ ] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

