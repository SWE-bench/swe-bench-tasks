> Proprietary concerns prevent me from sharing the query itself, I could try to boil it down to a mock version that replicates the error.

This would be needed before we can make any progress on this I'm afraid. The stack trace is good, and will help us identify the area of code, but without the SQL we can't know why and this issue will need to be closed.
@tunetheweb fair play, let me try to create a stripped down representation.
@tunetheweb there you go!
I managed to reproduce this in the latest `main`. Taking a quick look...
It fails when looking for templated position 198. The highest-numbered position in the `sliced_file` collection is 190. 
```
(Pdb) templated_pos
198
(Pdb) pp self.sliced_file
[TemplatedFileSlice(slice_type='templated', source_slice=slice(0, 103, None), templated_slice=slice(0, 0, None)),
 TemplatedFileSlice(slice_type='literal', source_slice=slice(103, 105, None), templated_slice=slice(0, 0, None)),
 TemplatedFileSlice(slice_type='block_start', source_slice=slice(105, 160, None), templated_slice=slice(0, 0, None)),
...
 TemplatedFileSlice(slice_type='literal', source_slice=slice(2822, 2823, None), templated_slice=slice(190, 190, None)),
 TemplatedFileSlice(slice_type='block_end', source_slice=slice(2823, 2834, None), templated_slice=slice(190, 190, None)),
 TemplatedFileSlice(slice_type='literal', source_slice=slice(2834, 2843, None), templated_slice=slice(190, 190, None)),
 TemplatedFileSlice(slice_type='block_end', source_slice=slice(2843, 2856, None), templated_slice=slice(190, 190, None)),
 TemplatedFileSlice(slice_type='literal', source_slice=slice(2856, 3358, None), templated_slice=slice(190, 190, None))]
(Pdb) 
```

The `sliced_file` is clearly wrong, because the rendered SQL is 2,083 characters long:
```
(Pdb) len(str(self))
2083
```
The templater is losing track of things at line 19 of the input file:
```
                coalesce({{features}}, (select feature_mode from {{ ref('second_list') }} where features = '{{features}}')) as {{features}}
```

Position 198 is where the code `{{features}}` renders, just after `coalesce(`.
The following simpler SQL can be used to reproduce the same issue:
```
select
    {%- for features in ["value4", "value5"] %}
        {%- if features in ["value7"] %}
            {{features}}
            {%- if not loop.last -%},{% endif %}
        {%- else -%}
            {{features}}
            {%- if not loop.last -%},{% endif %}
        {%- endif -%}
    {%- endfor %}
from my_table
```

This is another test case I extracted (may be the same bug, not sure):
```
{%- set first_list = ["value1", "value2", "value3"] -%}
{%- set second_list = ["value4", "value5", "value6"] -%}

with winsorize_data as (
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
    from ref('training_dataset')
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
@davesgonechina: I found a workaround if you want to try it. Don't use Jinja whitespace control. In other words, replace all occurrences of `{%-` with `{%` and all occurrences of `-%}` with `%}`.

I'll keep looking to see if I can find a fix. SQLFluff has had some past bugs involving whitespace control. Basically, it makes SQLFluff's job more challenging, when it tries to "map" the input SQL (before running Jinja) to the output file (after running Jinja).
In the file `src/sqlfluff/core/templaters/slicers/tracer.py`, I thought that the recently added function `_remove_block_whitespace_control` would eliminate any issues with whitespace control. It was added to fix _some_ issues like this. Perhaps this is a more complex situation?

Generally, avoiding whitespace control in the "alternate" template results in template output with more "breadcrumbs", making it easier for the tracer to deduce the execution path of the template. The issue we saw before (which may be happening here) is that the tracer loses track of the execution path and "drops" off the end of the template at some point. Should be fairly easy to find where (and why) this is happening. May be harder to fix. We shall see...