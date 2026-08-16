"ValueError: Position Not Found" with macro spanning entire file
## Expected Behaviour

`sqlfluff parse` should probably not fail with an exception and stack trace.

## Observed Behaviour

`sqlfluff parse` throws an exception, given an input file which is entirely spanned by a Jinja macro.

## Steps to Reproduce

```console
$ echo -n '{% macro foo() %}{% endmacro %}' | sqlfluff parse -
Traceback (most recent call last):
  File "/home/vladimir/work/extern/sqlfluff/venv/bin/sqlfluff", line 33, in <module>
    sys.exit(load_entry_point('sqlfluff', 'console_scripts', 'sqlfluff')())
  File "/home/vladimir/work/extern/sqlfluff/venv/lib/python3.9/site-packages/click/core.py", line 1137, in __call__
    return self.main(*args, **kwargs)
  File "/home/vladimir/work/extern/sqlfluff/venv/lib/python3.9/site-packages/click/core.py", line 1062, in main
    rv = self.invoke(ctx)
  File "/home/vladimir/work/extern/sqlfluff/venv/lib/python3.9/site-packages/click/core.py", line 1668, in invoke
    return _process_result(sub_ctx.command.invoke(sub_ctx))
  File "/home/vladimir/work/extern/sqlfluff/venv/lib/python3.9/site-packages/click/core.py", line 1404, in invoke
    return ctx.invoke(self.callback, **ctx.params)
  File "/home/vladimir/work/extern/sqlfluff/venv/lib/python3.9/site-packages/click/core.py", line 763, in invoke
    return __callback(*args, **kwargs)
  File "/home/vladimir/work/extern/sqlfluff/src/sqlfluff/cli/commands.py", line 701, in parse
    lnt.parse_string(
  File "/home/vladimir/work/extern/sqlfluff/src/sqlfluff/core/linter/linter.py", line 596, in parse_string
    return self.parse_rendered(rendered, recurse=recurse)
  File "/home/vladimir/work/extern/sqlfluff/src/sqlfluff/core/linter/linter.py", line 294, in parse_rendered
    tokens, lvs, config = cls._lex_templated_file(
  File "/home/vladimir/work/extern/sqlfluff/src/sqlfluff/core/linter/linter.py", line 127, in _lex_templated_file
    tokens, lex_vs = lexer.lex(templated_file)
  File "/home/vladimir/work/extern/sqlfluff/src/sqlfluff/core/parser/lexer.py", line 319, in lex
    segments: Tuple[RawSegment, ...] = self.elements_to_segments(
  File "/home/vladimir/work/extern/sqlfluff/src/sqlfluff/core/parser/lexer.py", line 346, in elements_to_segments
    source_slice = templated_file.templated_slice_to_source_slice(
  File "/home/vladimir/work/extern/sqlfluff/src/sqlfluff/core/templaters/base.py", line 319, in templated_slice_to_source_slice
    ts_stop_sf_start, ts_stop_sf_stop = self._find_slice_indices_of_templated_pos(
  File "/home/vladimir/work/extern/sqlfluff/src/sqlfluff/core/templaters/base.py", line 214, in _find_slice_indices_of_templated_pos
    raise ValueError("Position Not Found")
ValueError: Position Not Found
```

Note: the issue does not occur if the file ends with a newline. 

The contents of the macro also doesn't matter.

## Dialect

None specified

## Version
SQLFluff 6011bdbe05669b075045e8127cdf18cc537686d4, Python 3.9.6

## Configuration

None
