"Dropped elements in sequence matching" when doubled semicolon
## Expected Behaviour
Frankly, I'm not sure whether it (doubled `;`) should be just ignored or rather some specific rule should be triggered.
## Observed Behaviour
```console
(.venv) ?master ~/prod/_inne/sqlfluff> echo "select id from tbl;;" | sqlfluff lint -
Traceback (most recent call last):
  File "/home/adam/prod/_inne/sqlfluff/.venv/bin/sqlfluff", line 11, in <module>
    load_entry_point('sqlfluff', 'console_scripts', 'sqlfluff')()
  File "/home/adam/prod/_inne/sqlfluff/.venv/lib/python3.9/site-packages/click/core.py", line 1137, in __call__
    return self.main(*args, **kwargs)
  File "/home/adam/prod/_inne/sqlfluff/.venv/lib/python3.9/site-packages/click/core.py", line 1062, in main
    rv = self.invoke(ctx)
  File "/home/adam/prod/_inne/sqlfluff/.venv/lib/python3.9/site-packages/click/core.py", line 1668, in invoke
    return _process_result(sub_ctx.command.invoke(sub_ctx))
  File "/home/adam/prod/_inne/sqlfluff/.venv/lib/python3.9/site-packages/click/core.py", line 1404, in invoke
    return ctx.invoke(self.callback, **ctx.params)
  File "/home/adam/prod/_inne/sqlfluff/.venv/lib/python3.9/site-packages/click/core.py", line 763, in invoke
    return __callback(*args, **kwargs)
  File "/home/adam/prod/_inne/sqlfluff/src/sqlfluff/cli/commands.py", line 347, in lint
    result = lnt.lint_string_wrapped(sys.stdin.read(), fname="stdin")
  File "/home/adam/prod/_inne/sqlfluff/src/sqlfluff/core/linter/linter.py", line 789, in lint_string_wrapped
    linted_path.add(self.lint_string(string, fname=fname, fix=fix))
  File "/home/adam/prod/_inne/sqlfluff/src/sqlfluff/core/linter/linter.py", line 668, in lint_string
    parsed = self.parse_string(in_str=in_str, fname=fname, config=config)
  File "/home/adam/prod/_inne/sqlfluff/src/sqlfluff/core/linter/linter.py", line 607, in parse_string
    return self.parse_rendered(rendered, recurse=recurse)
  File "/home/adam/prod/_inne/sqlfluff/src/sqlfluff/core/linter/linter.py", line 313, in parse_rendered
    parsed, pvs = cls._parse_tokens(
  File "/home/adam/prod/_inne/sqlfluff/src/sqlfluff/core/linter/linter.py", line 190, in _parse_tokens
    parsed: Optional[BaseSegment] = parser.parse(
  File "/home/adam/prod/_inne/sqlfluff/src/sqlfluff/core/parser/parser.py", line 32, in parse
    parsed = root_segment.parse(parse_context=ctx)
  File "/home/adam/prod/_inne/sqlfluff/src/sqlfluff/core/parser/segments/base.py", line 821, in parse
    check_still_complete(segments, m.matched_segments, m.unmatched_segments)
  File "/home/adam/prod/_inne/sqlfluff/src/sqlfluff/core/parser/helpers.py", line 30, in check_still_complete
    raise RuntimeError(
RuntimeError: Dropped elements in sequence matching! 'select id from tbl;;' != ';'

```
## Steps to Reproduce
Run 
```console
echo "select id from tbl;;" | sqlfluff lint -
```
## Dialect
default (ansi)
## Version
```
sqlfluff, version 0.6.6
Python 3.9.5
```
## Configuration
None

