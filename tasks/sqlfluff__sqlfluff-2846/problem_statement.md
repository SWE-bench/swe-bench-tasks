ValueError: Position Not Found for lint/parse/fix, not clear why
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.


### What Happened

I have admittedly messy dbt sql model that gets the following error when I try to lint, parse or fix it with sqlfluff - every other model can be processed using the same settings, but this one throws the same error below even if I only run a single rule e.g. L009.

Unfortunately I cannot share the model itself but I can describe some notable features:
- begins with a dbt incremental config
- then sets three variables, each a list of strings
- Has two `for` loops with nested `if` conditions
- Has one very long line doing arithmetic operations involving both hardcoded values and columns from a two joined CTEs

### Expected Behaviour

Not the above error

### Observed Behaviour

```
WARNING    Unable to lint models/ltv_prediction_model/ltv_prediction.sql due to an internal error. Please report this as an issue w
ith your query's contents and stacktrace below!
To hide this warning, add the failing file to .sqlfluffignore
Traceback (most recent call last):
  File "/Users/dlyons/.pyenv/versions/3.9.4/lib/python3.9/site-packages/sqlfluff/core/linter/runner.py", line 103, in run
    yield partial()
  File "/Users/dlyons/.pyenv/versions/3.9.4/lib/python3.9/site-packages/sqlfluff/core/linter/linter.py", line 666, in lint_rendered
    parsed = cls.parse_rendered(rendered)
  File "/Users/dlyons/.pyenv/versions/3.9.4/lib/python3.9/site-packages/sqlfluff/core/linter/linter.py", line 352, in parse_rendere

d
    tokens, lvs, config = cls._lex_templated_file(
  File "/Users/dlyons/.pyenv/versions/3.9.4/lib/python3.9/site-packages/sqlfluff/core/linter/linter.py", line 139, in _lex_template
d_file
    tokens, lex_vs = lexer.lex(templated_file)
  File "/Users/dlyons/.pyenv/versions/3.9.4/lib/python3.9/site-packages/sqlfluff/core/parser/lexer.py", line 321, in lex
    segments: Tuple[RawSegment, ...] = self.elements_to_segments(
  File "/Users/dlyons/.pyenv/versions/3.9.4/lib/python3.9/site-packages/sqlfluff/core/parser/lexer.py", line 348, in elements_to_se
gments
    source_slice = templated_file.templated_slice_to_source_slice(
  File "/Users/dlyons/.pyenv/versions/3.9.4/lib/python3.9/site-packages/sqlfluff/core/templaters/base.py", line 294, in templated_s
lice_to_source_slice
    ts_stop_sf_start, ts_stop_sf_stop = self._find_slice_indices_of_templated_pos(
  File "/Users/dlyons/.pyenv/versions/3.9.4/lib/python3.9/site-packages/sqlfluff/core/templaters/base.py", line 180, in _find_slice
_indices_of_templated_pos
    raise ValueError("Position Not Found")
ValueError: Position Not Found
```

### How to reproduce

```
{{
    config(
        materialized='incremental',
        unique_key='md5_surrogate_key_main'
    )
}}

{%- set first_list = ["value1", "value2", "value3"] -%}
{%- set second_list = ["value4", "value5", "value6"] -%}
{%- set third_list = ["value7", "value8", "value9"] -%}

with fill_na_values as (
    select
        id,
        run_date,
        md5_surrogate_key_main,
        {%- for features in second_list %}
            {%- if features in third_list %}
                coalesce({{features}}, (select feature_mode from {{ ref('second_list') }} where features = '{{features}}')) as {{features}}
                {%- if not loop.last -%},{% endif %}
            {%- else -%}
                coalesce({{features}}, (select feature_mean from {{ ref('second_list') }} where features = '{{features}}')) as {{features}}
                {%- if not loop.last -%},{% endif %}
            {%- endif -%}
        {%- endfor %}
    from {{ ref('training_dataset') }}
    {%- if is_incremental() %}
    where current_date >= (select max(run_date) from {{ this }})
    {%- else %}
    where run_date >= '2021-01-01'
    {%- endif %}
),

winsorize_data as (
    select
        md5_surrogate_key_main,
        {%- for features in second_list %}
            {%- if features in first_list %}
                case
                    when {{features}} < (select fifth_percentile from {{ ref('first_list') }} where winsorize_column = '{{features}}')
                    then (select fifth_percentile from {{ ref('first_list') }} where winsorize_column = '{{features}}')
                    when {{features}} > (select ninetyfifth_percentile from {{ ref('first_list') }} where winsorize_column = '{{features}}')
                    then (select ninetyfifth_percentile from {{ ref('first_list') }} where winsorize_column = '{{features}}')
                    else {{features}}
                end as {{features}}
                {%- if not loop.last -%},{% endif %}
            {%- else %}
                {{features}}
                {%- if not loop.last -%},{% endif %}
            {%- endif %}
        {%- endfor %}
    from fill_na_values
),

scaling_data as (
    select
        md5_surrogate_key_main,
        {%- for features in second_list %}
            ({{features}} - (select feature_mean from {{ ref('second_list') }} where features = '{{features}}'))/(select feature_std from {{ ref('second_list') }} where features = '{{features}}') as {{features}}
            {%- if not loop.last -%},{% endif %}
        {%- endfor %}
    from winsorize_data
),

apply_ceofficients as (
    select
        md5_surrogate_key_main,
        {%- for features in second_list %}
            {{features}} * (select coefficients from {{ ref('second_list') }} where features = '{{features}}') as {{features}}_coef
            {%- if not loop.last -%},{% endif %}
        {%- endfor %}
    from scaling_data
),

logistic_prediction as (
    select
        fan.*,
        1/(1+EXP(-(0.24602303+coef1+coef2+coef3+coef4+coef5+coef6+coef7+coef8+coef9+available_balance_coef+coef10+coef11+coef12+coef13+coef14))) as prediction_probability,
        case when prediction_probability < .5 then 0 else 1 end as prediction_class
    from apply_ceofficients ac
    inner join fill_na_values fan
        on ac.md5_surrogate_key_main = fan.md5_surrogate_key_main
)

select * from logistic_prediction
```

### Dialect

Snowflake

### Version

0.10.1

### Configuration

```
[sqlfluff]
# verbose is an integer (0-2) indicating the level of log output
verbose = 0
# Turn off color formatting of output
nocolor = False
dialect = snowflake
templater = jinja
# Comma separated list of rules to check, or None for all
rules = L001,L002,L003,L004,L005,L009,L010,L013,L014,L015,L017,L018,L019,L020,L021,L022,L023,L024,L026,L027,L028,L030,L036,L037,L038,L039,L040,L044,L045,L046,L050,L051,L058,L061
# Comma separated list of rules to exclude, or None
exclude_rules = L006,L008,L011,L012,L025,L029,L031,L034,L035,L041,L042,L043,L052
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

[sqlfluff:indentation]
# See https://docs.sqlfluff.com/en/stable/indentation.html
indented_joins = False
indented_ctes = False
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

# Some rules can be configured directly from the config common to other rules
[sqlfluff:rules]
tab_space_size = 4
max_line_length = 80
indent_unit = space
comma_style = trailing
allow_scalar = True
single_table_references = consistent
unquoted_identifiers_policy = all

# Some rules have their own specific config
[sqlfluff:rules:L007]
operator_new_lines = after

[sqlfluff:rules:L010]
# Keywords
capitalisation_policy = consistent
# Comma separated list of words to ignore for this rule
ignore_words = None

[sqlfluff:rules:L011]
# Aliasing preference for tables
aliasing = explicit

[sqlfluff:rules:L012]
# Aliasing preference for columns
aliasing = explicit

[sqlfluff:rules:L014]
# Unquoted identifiers
extended_capitalisation_policy = consistent
# Comma separated list of words to ignore for this rule
ignore_words = None

[sqlfluff:rules:L016]
# Line length
ignore_comment_lines = False
ignore_comment_clauses = False

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

[sqlfluff:rules:L030]
# Function names
capitalisation_policy = consistent
# Comma separated list of words to ignore for this rule
ignore_words = None

[sqlfluff:rules:L038]
# Trailing commas
select_clause_trailing_comma = forbid

[sqlfluff:rules:L040]
# Null & Boolean Literals
capitalisation_policy = consistent
# Comma separated list of words to ignore for this rule
ignore_words = None

[sqlfluff:rules:L042]
# By default, allow subqueries in from clauses, but not join clauses
forbid_subquery_in = join

[sqlfluff:rules:L047]
# Consistent syntax to count all rows
prefer_count_1 = False
prefer_count_0 = False

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

[sqlfluff:rules:L059]
# Policy on quoted and unquoted identifiers
prefer_quoted_identifiers = False

[sqlfluff:rules:L062]
# Comma separated list of blocked words that should not be used
blocked_words = None

### Are you willing to work on and submit a PR to address the issue?

- [X] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)
```
