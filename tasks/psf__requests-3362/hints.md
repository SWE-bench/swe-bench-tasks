what does (your response object).encoding return?

There's at least one key difference: `decode_unicode=True` doesn't fall back to `apparent_encoding`, which means it'll never autodetect the encoding. This means if `response.encoding` is None it is a no-op: in fact, it's a no-op that yields bytes.

That behaviour seems genuinely bad to me, so I think we should consider it a bug. I'd rather we had the same logic as in `text` for this.

`r.encoding` returns `None`.

On a related note, `iter_text` might be clearer/more consistent than `iter_content(decode_unicode=True)` if there's room for change in the APIs future (and `iter_content_lines` and `iter_text_lines` I guess), assuming you don't see that as bloat.

@mikepelley The API is presently frozen so I don't think we'll be adding those three methods. Besides, `iter_text` likely wouldn't provide much extra value outside of calling `iter_content(decode_unicode=True)`.
