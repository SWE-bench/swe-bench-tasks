> Version
> sqlfluff, version 0.6.2

Is this correct? If so that is a VERY old version so please upgrade. Though confirmed this is still an issue in latest. But still, going to need to upgrade to get any fix for this.
> > Version
> > sqlfluff, version 0.6.2
> 
> Is this correct? If so that is a VERY old version so please upgrade. Though confirmed this is still an issue in latest. But still, going to need to upgrade to get any fix for this.

Thanks for your response! I had sqlfluff globally installed with version 0.6.2 but i changed it now to 0.11.0 and still it is the same issue.
The rule probably needs updating to be "template aware".  A few other rules have required similar updates and may provide useful inspiration for a fix.

```
src/sqlfluff/rules/L019.py
140:                    and not last_seg.is_templated
209:                if last_seg.is_type("comma") and not context.segment.is_templated:

src/sqlfluff/rules/L003.py
77:        if elem.is_type("whitespace") and elem.is_templated:
148:                templated_line = elem.is_templated

src/sqlfluff/rules/L010.py
87:        if context.segment.is_templated:
```
I can't reproduce this issue with SQLFluff 0.11.0. This is the terminal output I get:
```
(sqlfluff-0.11.0) ➜  /tmp sqlfluff fix test.template.sql
==== sqlfluff ====
sqlfluff:               0.11.0 python:                  3.9.1
implementation:        cpython dialect:             snowflake
verbosity:                   1 templater:               jinja

==== finding fixable violations ====
=== [ path: test.template.sql ] ===

== [test.template.sql] FAIL                                                                                                                                                                             
L:   2 | P:   1 | L003 | Indent expected and not found compared to line #1                                                                                                                              
==== fixing violations ====
1 fixable linting violations found
Are you sure you wish to attempt to fix these? [Y/n] ...
Attempting fixes...
Persisting Changes...
== [test.template.sql] PASS
Done. Please check your files to confirm.
All Finished 📜 🎉!
```

And this is the resulting file. SQLFluff indented line 2 but no newline was added.
```
{% if true %}
    SELECT 1 + 1
{%- endif %}
```
I can @barrywhart but it only works when the final newline in the file doesn't exist.

If on mac you can run something like this to strip the final newline character:

```
truncate -s -1 test.sql > test2.sql
```

Then fix `test2.sql` with default config and you'll see it.
There's a bug in `JinjaTracer` -- if a Jinja block (e.g. `{% endif %}` is the final slice in the file (i. there's no final newline), that slice is missing from the output. This will have to be fixed before we can fix L009, because at present, L009 cannot "see" that `{% endif %}` after the `1`.