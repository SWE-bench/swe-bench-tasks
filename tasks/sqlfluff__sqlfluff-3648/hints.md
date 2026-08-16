This is a curious error. Can you run `dbt compile` and post what dbt expects the compiled form of this statement to be? I worry that while a query is run at compile time, this query otherwise compiles to an empty file - and that could be causing issues.
dbt compile doesn't output the call statement blocks since they're interpreted at runtime; however, we can see the output ran on the snowflake query history.

Source test.sql
```
{% call statement('variables', fetch_result=true) %}

    select 1

{% endcall %}

with source (
    select 1
)

select * from source
```

Compiled output of test.sql
```


with source (
    select 1
)

select * from source
```
The dbt [documentation](https://docs.getdbt.com/reference/dbt-jinja-functions/statement-blocks) mentions re: `statement()`:

>Volatile API
>While the statement and load_result setup works for now, we intend to improve this interface in the future. If you have questions or suggestions, please let us know in GitHub or on Slack.

So this might be a relatively lower priority issue. IIUC, it may also be dbt specific (not affecting the `jinja` templater).


I did some preliminary investigation. IIUC, SQLFluff's `JinjaTracer` should treat this:
```
{% call statement('variables', fetch_result=true) %}

select 1 as test;

{% endcall %}
```

like this:
```
{{ statement('variables', fetch_result=true) }}
```

In both cases, whatever `statement()` returns is passed through to the template output. I think this will be pretty straightforward, other than the usual trickiness of working on this complex area of the code.