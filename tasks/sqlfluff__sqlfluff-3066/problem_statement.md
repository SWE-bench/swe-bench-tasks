Jinja: sqlfluff fails in the presence of assignments with multiple targets
### Search before asking

- [X] I searched the [issues](https://github.com/sqlfluff/sqlfluff/issues) and found no similar issues.

I did search, and I think this _may_ be related, but since no more information was provided I cannot confirm it: https://github.com/sqlfluff/sqlfluff/issues/2947. For this reason, I opened a new issue.

### What Happened

Jinja templates support multiple targets in [assignments](https://jinja.palletsprojects.com/en/3.0.x/templates/#assignments). However, `sqlfluff` fails to lint a file in the presence of an assignment with multiple targets.

I traced this back to the `update_inside_set_or_macro` function, specifically [this line](https://github.com/sqlfluff/sqlfluff/blob/main/src/sqlfluff/core/templaters/slicers/tracer.py#L244=).

The way `sqlfluff` is determining whether we are inside a [block assignment](https://jinja.palletsprojects.com/en/3.0.x/templates/#block-assignments) is by checking for the presence of an equals in the second index of the trimmed parts of the current raw slice:

```python
if len(filtered_trimmed_parts) < 3 or filtered_trimmed_parts[2] != "=":
```

This condition is false for single target assignments:

```sql
{% set a = 1 %}
```

Which produce the expected trimmed parts (with spaces removed as in [line 243](https://github.com/sqlfluff/sqlfluff/blob/main/src/sqlfluff/core/templaters/slicers/tracer.py#L243=)):

```python
['set', 'a', '=', '1']
#             2    
```

However, with multiple targets:

```sql
{% set a, b = 1, 2 %}
```

```python
['set', 'a', ',', 'b', '=', '1', '2']
#                       4    
```

Equals is no longer in the index 2, but has been bumped to index 4, yet we are not in the expanded block form of set assignments. This causes the `inside_set_or_macro` flag to be incorrectly set to `True`, as if we were using a block assignment, which causes the entire template to be ignored (or something like that), and leads to the eventual `ValueError` raised.

I played around a bit with potential solutions: first, I tried incrementing the index of the equals by the number of commas:

```python
equals_index = 2 + sum((c == ',' for c in  filtered_trimmed_parts))
if len(filtered_trimmed_parts) < 3 or filtered_trimmed_parts[equals_index] != "=":
```

However, this would bring issues if using the expanded form of set assignments with any commas in it, or in the presence of an uneven number of commas on both sides of the assignment.

Another simpler option would be to check for the presence of a single equals:

```python
if len(filtered_trimmed_parts) < 3 or filtered_trimmed_parts.count("=") != 1:
```

This one seems more promising, specially considering that multiple targets appear not to be supported with block assignments (at least, that's what I think, as the docs don't mention it, and trying it locally raises a too many values to unpack error). Thus, the first condition will always be true for block assignments (so, even the presence of an equals in the body of the assignment would not cause issues).

### Expected Behaviour

sqlfluff should lint files properly, even in the presence of assignments with multiple targets.

### Observed Behaviour

Linting fails when an exception is raised:

```
Traceback (most recent call last):
  File "/home/tomasfarias/.pyenv/versions/3.10dbt/bin/sqlfluff", line 8, in <module>
    sys.exit(cli())
  File "/home/tomasfarias/.pyenv/versions/3.10.2/envs/3.10dbt/lib/python3.10/site-packages/click/core.py", line 1128, in __call__
    return self.main(*args, **kwargs)
  File "/home/tomasfarias/.pyenv/versions/3.10.2/envs/3.10dbt/lib/python3.10/site-packages/click/core.py", line 1053, in main
    rv = self.invoke(ctx)
  File "/home/tomasfarias/.pyenv/versions/3.10.2/envs/3.10dbt/lib/python3.10/site-packages/click/core.py", line 1659, in invoke
    return _process_result(sub_ctx.command.invoke(sub_ctx))
  File "/home/tomasfarias/.pyenv/versions/3.10.2/envs/3.10dbt/lib/python3.10/site-packages/click/core.py", line 1395, in invoke
    return ctx.invoke(self.callback, **ctx.params)
  File "/home/tomasfarias/.pyenv/versions/3.10.2/envs/3.10dbt/lib/python3.10/site-packages/click/core.py", line 754, in invoke
    return __callback(*args, **kwargs)
  File "/home/tomasfarias/.pyenv/versions/3.10.2/envs/3.10dbt/lib/python3.10/site-packages/sqlfluff/cli/commands.py", line 541, in lint
    result = lnt.lint_paths(
  File "/home/tomasfarias/.pyenv/versions/3.10.2/envs/3.10dbt/lib/python3.10/site-packages/sqlfluff/core/linter/linter.py", line 1098, in lint_paths
    self.lint_path(
  File "/home/tomasfarias/.pyenv/versions/3.10.2/envs/3.10dbt/lib/python3.10/site-packages/sqlfluff/core/linter/linter.py", line 1050, in lint_path
    for i, linted_file in enumerate(runner.run(fnames, fix), start=1):
  File "/home/tomasfarias/.pyenv/versions/3.10.2/envs/3.10dbt/lib/python3.10/site-packages/sqlfluff/core/linter/runner.py", line 101, in run
    for fname, partial in self.iter_partials(fnames, fix=fix):
  File "/home/tomasfarias/.pyenv/versions/3.10.2/envs/3.10dbt/lib/python3.10/site-packages/sqlfluff/core/linter/runner.py", line 54, in iter_partials
    for fname, rendered in self.iter_rendered(fnames):
  File "/home/tomasfarias/.pyenv/versions/3.10.2/envs/3.10dbt/lib/python3.10/site-packages/sqlfluff/core/linter/runner.py", line 43, in iter_rendered
    yield fname, self.linter.render_file(fname, self.config)
  File "/home/tomasfarias/.pyenv/versions/3.10.2/envs/3.10dbt/lib/python3.10/site-packages/sqlfluff/core/linter/linter.py", line 771, in render_file
    return self.render_string(raw_file, fname, config, encoding)
  File "/home/tomasfarias/.pyenv/versions/3.10.2/envs/3.10dbt/lib/python3.10/site-packages/sqlfluff/core/linter/linter.py", line 742, in render_string
    templated_file, templater_violations = self.templater.process(
  File "/home/tomasfarias/.pyenv/versions/3.10.2/envs/3.10dbt/lib/python3.10/site-packages/sqlfluff/core/templaters/jinja.py", line 394, in process
    TemplatedFile(
  File "/home/tomasfarias/.pyenv/versions/3.10.2/envs/3.10dbt/lib/python3.10/site-packages/sqlfluff/core/templaters/base.py", line 94, in __init__
    raise ValueError("Cannot instantiate a templated file unsliced!")
ValueError: Cannot instantiate a templated file unsliced!
```

### How to reproduce

1. Save the following template to `model.sql` in an empty directory:
```sql
{% set a, b = 1, 2 %}

SELECT {{ a }}
```
2. Run `sqlfluff lint model.sql --dialect 'postgres'`


### Dialect

Tried with postgres and redshift dialects, however I think others may be affected as long as they use jinja templates.

### Version

v0.12.0

### Configuration

Nothing, ran from an empty directory.

### Are you willing to work on and submit a PR to address the issue?

- [X] Yes I am willing to submit a PR!

### Code of Conduct

- [X] I agree to follow this project's [Code of Conduct](https://github.com/sqlfluff/sqlfluff/blob/main/CODE_OF_CONDUCT.md)

