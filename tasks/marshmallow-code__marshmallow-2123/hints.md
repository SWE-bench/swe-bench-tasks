Maybe an additional flag `absolute` that would default to `True`?

Would you like to work on this?
@lafrech Thank you for commenting. 

My thinking would be that flavors could be selected individually, as if flags are used, so they could be combined. Something along these lines:

```
args = {
    "ref": fields.URL(kind=fields.URL.absolute | fields.URL.relative)
    # OR
    "ref": fields.URL(kind=["absolute", "relative"])
```

This also would allow to retain backward compatibility for existing `relative=True|False`, which would be translated to these flags combined or just absolute flag being used.

An extra Boolean would work fine as well.  It would be similar to how Joi handles it:

https://joi.dev/api/?v=17.9.1#stringurioptions

As for me fixing it, I'm not sure - the evaluation of the attribute for relative URLs is integrated in a pretty intricate regex construction with those Booleans used as keys. This change sounds bigger than I could commit to at this point. My apologies. Please feel free to close this issue if there's no one else interested in it.
I'm not very proficient with regexes, although the change involved here should be marginal (the regex is already conditional due to the absolute flag).

I won't take the time to do it but I don't mind keeping this open for now.