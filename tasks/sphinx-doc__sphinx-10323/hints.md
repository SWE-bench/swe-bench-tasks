Docutils; the reST parser library ignores the leading whitespaces of directive options. So it's difficult to handle it from directive implementation.

>Use of dedent could be a good solution, if dedent was applied only to the literalinclude and not to the prepend and append content.

Sounds good. The combination of `dedent` and `prepend` options are not intended. So it should be fixed.