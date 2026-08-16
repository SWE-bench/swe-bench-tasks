Hi @CyberShadow, @tunetheweb, what is expected output of
```console
$ echo -n '{% macro foo() %}{% endmacro %}' | sqlfluff parse -
```
?

Probably the same as the input. Definitely not an exception, in any case.

Edit: Whoops, forgot this was a `parse` case. What @tunetheweb said below, then.
For parse we don't return input.

If we add a newline we get this:

```
% echo -n '{% macro foo() %}{% endmacro %}\n' | sqlfluff parse -
[L:  1, P:  1]      |file:
[L:  1, P:  1]      |    [META] placeholder:                                       [Type: 'compound', Raw: '{% macro foo() %}{% endmacro %}']
[L:  1, P: 32]      |    newline:                                                  '\n'
```

So I'd expect the first two lines to be returned if newline isn't given.

Here's some "equivalent" non-SQL that doesn't fail:

```
% echo " " | sqlfluff parse -     
[L:  1, P:  1]      |file:
[L:  1, P:  1]      |    whitespace:                                               ' '
[L:  1, P:  2]      |    newline:                                                  '\n'

% echo "" | sqlfluff parse - 
[L:  1, P:  1]      |file:
[L:  1, P:  1]      |    newline:                                                  '\n'

% echo "--test" | sqlfluff parse -
[L:  1, P:  1]      |file:
[L:  1, P:  1]      |    comment:                                                  '--test'
[L:  1, P:  7]      |    newline:                                                  '\n'
``


