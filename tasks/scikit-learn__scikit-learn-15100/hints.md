Good catch. Are you able to provide a fix?
It looks like we should just remove the `if` branch from `strip_accents_unicode`:

```python
def strip_accents_unicode(s):
    normalized = unicodedata.normalize('NFKD', s)
    return ''.join([c for c in normalized if not unicodedata.combining(c)])
```

If that sounds good to you I can put together a PR shortly.
A pr with that fix and some tests sounds very welcome.

Indeed this is a bug and the solution proposed seems correct. +1 for a PR with a non-regression test.