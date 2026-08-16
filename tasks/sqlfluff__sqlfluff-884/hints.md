To triage this issue, I searched the SQLFluff code to find all uses of `is_whitespace`. This is the only one I found:
```
src/sqlfluff/core/parser/segments/base.py:72:    is_whitespace = False
```

@alanmcruickshank: What's the purpose of `is_whitespace`?

I see that long ago (2019), there was a class `WhitespaceSegment` (also a `NewlineSegment`). Now it's not a class -- instead, it'd defined in `src/sqlfluff/core/rules/base.py`.
Once #866 is merged I'll pick up the rest of this which relates to some of the lexer objects.