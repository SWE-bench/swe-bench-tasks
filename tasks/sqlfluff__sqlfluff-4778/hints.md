I think think this is almost certainly about the `do` statement, hopefully this should be very solvable.
Any pointers on where I should start looking if I would work on a fix @alanmcruickshank?
@fredriv - great question. I just had a quick look and this is a very strange bug, but hopefully one with a satisfying solution.

If I run `sqlfluff parse` on the file I get this:

```
[L:  1, P:  1]      |file:
[L:  1, P:  1]      |    [META] placeholder:                                       [Type: 'templated', Raw: "{% set cols = ['a', 'b'] %}"]
[L:  1, P: 28]      |    newline:                                                  '\n'
[L:  2, P:  1]      |    [META] placeholder:                                       [Type: 'block_start', Raw: "{% do cols.remove('a') %}", Block: '230a18']
[L:  2, P: 26]      |    newline:                                                  '\n'
[L:  3, P:  1]      |    newline:                                                  '\n'
[L:  4, P:  1]      |    [META] placeholder:                                       [Type: 'block_start', Raw: '{% if true %}', Block: 'e33036']
[L:  4, P: 14]      |    newline:                                                  '\n'
[L:  5, P:  1]      |    whitespace:                                               '    '
[L:  5, P:  5]      |    statement:
[L:  5, P:  5]      |        select_statement:
[L:  5, P:  5]      |            select_clause:
[L:  5, P:  5]      |                keyword:                                      'select'
[L:  5, P: 11]      |                [META] indent:
[L:  5, P: 11]      |                whitespace:                                   ' '
[L:  5, P: 12]      |                select_clause_element:
[L:  5, P: 12]      |                    column_reference:
[L:  5, P: 12]      |                        naked_identifier:                     'a'
[L:  5, P: 13]      |            newline:                                          '\n'
[L:  6, P:  1]      |            whitespace:                                       '    '
[L:  6, P:  5]      |            [META] dedent:
[L:  6, P:  5]      |            from_clause:
[L:  6, P:  5]      |                keyword:                                      'from'
[L:  6, P:  9]      |                whitespace:                                   ' '
[L:  6, P: 10]      |                from_expression:
[L:  6, P: 10]      |                    [META] indent:
[L:  6, P: 10]      |                    from_expression_element:
[L:  6, P: 10]      |                        table_expression:
[L:  6, P: 10]      |                            table_reference:
[L:  6, P: 10]      |                                naked_identifier:             'some_table'
[L:  6, P: 20]      |                    [META] dedent:
[L:  6, P: 20]      |    newline:                                                  '\n'
[L:  7, P:  1]      |    [META] placeholder:                                       [Type: 'block_end', Raw: '{% endif %}', Block: 'e33036']
[L:  7, P: 12]      |    [META] end_of_file:
```

Note the difference between that and the output when I remove the `do` line:

```
[L:  1, P:  1]      |file:
[L:  1, P:  1]      |    [META] placeholder:                                       [Type: 'templated', Raw: "{% set cols = ['a', 'b'] %}"]
[L:  1, P: 28]      |    newline:                                                  '\n'
[L:  2, P:  1]      |    newline:                                                  '\n'
[L:  3, P:  1]      |    newline:                                                  '\n'
[L:  4, P:  1]      |    [META] placeholder:                                       [Type: 'block_start', Raw: '{% if true %}', Block: '0d1e98']
[L:  4, P: 14]      |    [META] indent:                                            [Block: '0d1e98']
[L:  4, P: 14]      |    newline:                                                  '\n'
[L:  5, P:  1]      |    whitespace:                                               '    '
[L:  5, P:  5]      |    statement:
[L:  5, P:  5]      |        select_statement:
[L:  5, P:  5]      |            select_clause:
[L:  5, P:  5]      |                keyword:                                      'select'
[L:  5, P: 11]      |                [META] indent:
[L:  5, P: 11]      |                whitespace:                                   ' '
[L:  5, P: 12]      |                select_clause_element:
[L:  5, P: 12]      |                    column_reference:
[L:  5, P: 12]      |                        naked_identifier:                     'a'
[L:  5, P: 13]      |            newline:                                          '\n'
[L:  6, P:  1]      |            whitespace:                                       '    '
[L:  6, P:  5]      |            [META] dedent:
[L:  6, P:  5]      |            from_clause:
[L:  6, P:  5]      |                keyword:                                      'from'
[L:  6, P:  9]      |                whitespace:                                   ' '
[L:  6, P: 10]      |                from_expression:
[L:  6, P: 10]      |                    [META] indent:
[L:  6, P: 10]      |                    from_expression_element:
[L:  6, P: 10]      |                        table_expression:
[L:  6, P: 10]      |                            table_reference:
[L:  6, P: 10]      |                                naked_identifier:             'some_table'
[L:  6, P: 20]      |                    [META] dedent:
[L:  6, P: 20]      |    newline:                                                  '\n'
[L:  7, P:  1]      |    [META] dedent:                                            [Block: '0d1e98']
[L:  7, P:  1]      |    [META] placeholder:                                       [Type: 'block_end', Raw: '{% endif %}', Block: '0d1e98']
[L:  7, P: 12]      |    [META] end_of_file:
```

See that in the latter example there are `indent` and `dedent` tokens around the `if` clause, but not in the first example. Something about the `do` call is disrupting the positioning of those indent tokens. Those tokens are inserted during `._iter_segments()` in `lexer.py`, and more specifically in `._handle_zero_length_slice()`. That's probably where you'll find the issue. My guess is that something about the `do` block is throwing off the block tracking?
Thanks! I'll see if I can have a look at it tonight.

Could it have something to do with the `do` block not having a corresponding `block_end`? 🤔
So perhaps it should be `templated` instead of `block_start`, similar to the `set` above it?
If I add `do` to the list of tag names in `extract_block_type` at https://github.com/sqlfluff/sqlfluff/blob/main/src/sqlfluff/core/templaters/slicers/tracer.py#L527 it regards it as a `templated` element instead of `block_start`, and the indent is added where I want it.

E.g.
```
[L:  1, P:  1]      |file:
[L:  1, P:  1]      |    [META] placeholder:                                       [Type: 'templated', Raw: "{% set cols = ['a', 'b'] %}"]
[L:  1, P: 28]      |    newline:                                                  '\n'
[L:  2, P:  1]      |    [META] placeholder:                                       [Type: 'templated', Raw: "{% do cols.remove('a') %}"]
[L:  2, P: 26]      |    newline:                                                  '\n'
[L:  3, P:  1]      |    newline:                                                  '\n'
[L:  4, P:  1]      |    [META] placeholder:                                       [Type: 'block_start', Raw: '{% if true %}', Block: '3e39bd']
[L:  4, P: 14]      |    [META] indent:                                            [Block: '3e39bd']
[L:  4, P: 14]      |    newline:                                                  '\n'
[L:  5, P:  1]      |    whitespace:                                               '    '
[L:  5, P:  5]      |    statement:
[L:  5, P:  5]      |        select_statement:
[L:  5, P:  5]      |            select_clause:
[L:  5, P:  5]      |                keyword:                                      'select'
[L:  5, P: 11]      |                [META] indent:
[L:  5, P: 11]      |                whitespace:                                   ' '
[L:  5, P: 12]      |                select_clause_element:
[L:  5, P: 12]      |                    column_reference:
[L:  5, P: 12]      |                        naked_identifier:                     'a'
[L:  5, P: 13]      |            newline:                                          '\n'
[L:  6, P:  1]      |            whitespace:                                       '    '
[L:  6, P:  5]      |            [META] dedent:
[L:  6, P:  5]      |            from_clause:
[L:  6, P:  5]      |                keyword:                                      'from'
[L:  6, P:  9]      |                whitespace:                                   ' '
[L:  6, P: 10]      |                from_expression:
[L:  6, P: 10]      |                    [META] indent:
[L:  6, P: 10]      |                    from_expression_element:
[L:  6, P: 10]      |                        table_expression:
[L:  6, P: 10]      |                            table_reference:
[L:  6, P: 10]      |                                naked_identifier:             'some_table'
[L:  6, P: 20]      |                    [META] dedent:
[L:  6, P: 20]      |    newline:                                                  '\n'
[L:  7, P:  1]      |    [META] dedent:                                            [Block: '3e39bd']
[L:  7, P:  1]      |    [META] placeholder:                                       [Type: 'block_end', Raw: '{% endif %}', Block: '3e39bd']
[L:  7, P: 12]      |    newline:                                                  '\n'
[L:  8, P:  1]      |    [META] end_of_file:
```
Similarly if I instead add `do` to the list of trimmed parts in `update_inside_set_call_macro_or_block` at https://github.com/sqlfluff/sqlfluff/blob/main/src/sqlfluff/core/templaters/slicers/tracer.py#L252-L255

Maybe a better place to put it? What do you think @alanmcruickshank?
@fredriv - based on the [docs for jinja](https://jinja.palletsprojects.com/en/3.0.x/extensions/#expression-statement) it looks like we should never get a "do block" (i.e. `{% do ... %} ... {% enddo %}`, it's only ever just `{% do ... %}`). That means that treating it like a `templated` section is the right route, i.e. we should add it in `extract_block_type` and not in `update_inside_set_call_macro_or_block`.

Thanks for your research - I think this should be a neat solution! 🚀 
👍 Ok, I can make a PR :)
I think think this is almost certainly about the `do` statement, hopefully this should be very solvable.
Any pointers on where I should start looking if I would work on a fix @alanmcruickshank?
@fredriv - great question. I just had a quick look and this is a very strange bug, but hopefully one with a satisfying solution.

If I run `sqlfluff parse` on the file I get this:

```
[L:  1, P:  1]      |file:
[L:  1, P:  1]      |    [META] placeholder:                                       [Type: 'templated', Raw: "{% set cols = ['a', 'b'] %}"]
[L:  1, P: 28]      |    newline:                                                  '\n'
[L:  2, P:  1]      |    [META] placeholder:                                       [Type: 'block_start', Raw: "{% do cols.remove('a') %}", Block: '230a18']
[L:  2, P: 26]      |    newline:                                                  '\n'
[L:  3, P:  1]      |    newline:                                                  '\n'
[L:  4, P:  1]      |    [META] placeholder:                                       [Type: 'block_start', Raw: '{% if true %}', Block: 'e33036']
[L:  4, P: 14]      |    newline:                                                  '\n'
[L:  5, P:  1]      |    whitespace:                                               '    '
[L:  5, P:  5]      |    statement:
[L:  5, P:  5]      |        select_statement:
[L:  5, P:  5]      |            select_clause:
[L:  5, P:  5]      |                keyword:                                      'select'
[L:  5, P: 11]      |                [META] indent:
[L:  5, P: 11]      |                whitespace:                                   ' '
[L:  5, P: 12]      |                select_clause_element:
[L:  5, P: 12]      |                    column_reference:
[L:  5, P: 12]      |                        naked_identifier:                     'a'
[L:  5, P: 13]      |            newline:                                          '\n'
[L:  6, P:  1]      |            whitespace:                                       '    '
[L:  6, P:  5]      |            [META] dedent:
[L:  6, P:  5]      |            from_clause:
[L:  6, P:  5]      |                keyword:                                      'from'
[L:  6, P:  9]      |                whitespace:                                   ' '
[L:  6, P: 10]      |                from_expression:
[L:  6, P: 10]      |                    [META] indent:
[L:  6, P: 10]      |                    from_expression_element:
[L:  6, P: 10]      |                        table_expression:
[L:  6, P: 10]      |                            table_reference:
[L:  6, P: 10]      |                                naked_identifier:             'some_table'
[L:  6, P: 20]      |                    [META] dedent:
[L:  6, P: 20]      |    newline:                                                  '\n'
[L:  7, P:  1]      |    [META] placeholder:                                       [Type: 'block_end', Raw: '{% endif %}', Block: 'e33036']
[L:  7, P: 12]      |    [META] end_of_file:
```

Note the difference between that and the output when I remove the `do` line:

```
[L:  1, P:  1]      |file:
[L:  1, P:  1]      |    [META] placeholder:                                       [Type: 'templated', Raw: "{% set cols = ['a', 'b'] %}"]
[L:  1, P: 28]      |    newline:                                                  '\n'
[L:  2, P:  1]      |    newline:                                                  '\n'
[L:  3, P:  1]      |    newline:                                                  '\n'
[L:  4, P:  1]      |    [META] placeholder:                                       [Type: 'block_start', Raw: '{% if true %}', Block: '0d1e98']
[L:  4, P: 14]      |    [META] indent:                                            [Block: '0d1e98']
[L:  4, P: 14]      |    newline:                                                  '\n'
[L:  5, P:  1]      |    whitespace:                                               '    '
[L:  5, P:  5]      |    statement:
[L:  5, P:  5]      |        select_statement:
[L:  5, P:  5]      |            select_clause:
[L:  5, P:  5]      |                keyword:                                      'select'
[L:  5, P: 11]      |                [META] indent:
[L:  5, P: 11]      |                whitespace:                                   ' '
[L:  5, P: 12]      |                select_clause_element:
[L:  5, P: 12]      |                    column_reference:
[L:  5, P: 12]      |                        naked_identifier:                     'a'
[L:  5, P: 13]      |            newline:                                          '\n'
[L:  6, P:  1]      |            whitespace:                                       '    '
[L:  6, P:  5]      |            [META] dedent:
[L:  6, P:  5]      |            from_clause:
[L:  6, P:  5]      |                keyword:                                      'from'
[L:  6, P:  9]      |                whitespace:                                   ' '
[L:  6, P: 10]      |                from_expression:
[L:  6, P: 10]      |                    [META] indent:
[L:  6, P: 10]      |                    from_expression_element:
[L:  6, P: 10]      |                        table_expression:
[L:  6, P: 10]      |                            table_reference:
[L:  6, P: 10]      |                                naked_identifier:             'some_table'
[L:  6, P: 20]      |                    [META] dedent:
[L:  6, P: 20]      |    newline:                                                  '\n'
[L:  7, P:  1]      |    [META] dedent:                                            [Block: '0d1e98']
[L:  7, P:  1]      |    [META] placeholder:                                       [Type: 'block_end', Raw: '{% endif %}', Block: '0d1e98']
[L:  7, P: 12]      |    [META] end_of_file:
```

See that in the latter example there are `indent` and `dedent` tokens around the `if` clause, but not in the first example. Something about the `do` call is disrupting the positioning of those indent tokens. Those tokens are inserted during `._iter_segments()` in `lexer.py`, and more specifically in `._handle_zero_length_slice()`. That's probably where you'll find the issue. My guess is that something about the `do` block is throwing off the block tracking?
Thanks! I'll see if I can have a look at it tonight.

Could it have something to do with the `do` block not having a corresponding `block_end`? 🤔
So perhaps it should be `templated` instead of `block_start`, similar to the `set` above it?
If I add `do` to the list of tag names in `extract_block_type` at https://github.com/sqlfluff/sqlfluff/blob/main/src/sqlfluff/core/templaters/slicers/tracer.py#L527 it regards it as a `templated` element instead of `block_start`, and the indent is added where I want it.

E.g.
```
[L:  1, P:  1]      |file:
[L:  1, P:  1]      |    [META] placeholder:                                       [Type: 'templated', Raw: "{% set cols = ['a', 'b'] %}"]
[L:  1, P: 28]      |    newline:                                                  '\n'
[L:  2, P:  1]      |    [META] placeholder:                                       [Type: 'templated', Raw: "{% do cols.remove('a') %}"]
[L:  2, P: 26]      |    newline:                                                  '\n'
[L:  3, P:  1]      |    newline:                                                  '\n'
[L:  4, P:  1]      |    [META] placeholder:                                       [Type: 'block_start', Raw: '{% if true %}', Block: '3e39bd']
[L:  4, P: 14]      |    [META] indent:                                            [Block: '3e39bd']
[L:  4, P: 14]      |    newline:                                                  '\n'
[L:  5, P:  1]      |    whitespace:                                               '    '
[L:  5, P:  5]      |    statement:
[L:  5, P:  5]      |        select_statement:
[L:  5, P:  5]      |            select_clause:
[L:  5, P:  5]      |                keyword:                                      'select'
[L:  5, P: 11]      |                [META] indent:
[L:  5, P: 11]      |                whitespace:                                   ' '
[L:  5, P: 12]      |                select_clause_element:
[L:  5, P: 12]      |                    column_reference:
[L:  5, P: 12]      |                        naked_identifier:                     'a'
[L:  5, P: 13]      |            newline:                                          '\n'
[L:  6, P:  1]      |            whitespace:                                       '    '
[L:  6, P:  5]      |            [META] dedent:
[L:  6, P:  5]      |            from_clause:
[L:  6, P:  5]      |                keyword:                                      'from'
[L:  6, P:  9]      |                whitespace:                                   ' '
[L:  6, P: 10]      |                from_expression:
[L:  6, P: 10]      |                    [META] indent:
[L:  6, P: 10]      |                    from_expression_element:
[L:  6, P: 10]      |                        table_expression:
[L:  6, P: 10]      |                            table_reference:
[L:  6, P: 10]      |                                naked_identifier:             'some_table'
[L:  6, P: 20]      |                    [META] dedent:
[L:  6, P: 20]      |    newline:                                                  '\n'
[L:  7, P:  1]      |    [META] dedent:                                            [Block: '3e39bd']
[L:  7, P:  1]      |    [META] placeholder:                                       [Type: 'block_end', Raw: '{% endif %}', Block: '3e39bd']
[L:  7, P: 12]      |    newline:                                                  '\n'
[L:  8, P:  1]      |    [META] end_of_file:
```
Similarly if I instead add `do` to the list of trimmed parts in `update_inside_set_call_macro_or_block` at https://github.com/sqlfluff/sqlfluff/blob/main/src/sqlfluff/core/templaters/slicers/tracer.py#L252-L255

Maybe a better place to put it? What do you think @alanmcruickshank?
@fredriv - based on the [docs for jinja](https://jinja.palletsprojects.com/en/3.0.x/extensions/#expression-statement) it looks like we should never get a "do block" (i.e. `{% do ... %} ... {% enddo %}`, it's only ever just `{% do ... %}`). That means that treating it like a `templated` section is the right route, i.e. we should add it in `extract_block_type` and not in `update_inside_set_call_macro_or_block`.

Thanks for your research - I think this should be a neat solution! 🚀 
👍 Ok, I can make a PR :)