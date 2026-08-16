@lafrech Would you mind looking into this?
Thanks for reporting.

This is definitely a side effect of https://github.com/marshmallow-code/marshmallow/pull/1249/files. Sorry about that.

I don't own a copy of the spec, so the work on this is based on examples... I assumed that microseconds always came as a six-pack. It seems only three digits (your example) is acceptable. From what I understand in the regex we copied from Django, we could even expect any number of digits in [1; 6].

I see two solutions to this:

- Split around `"."`, then in the right part, get all numbers and ignore letters/symbols.
- Split around `"."`, then split the right part around anything that delimitates a timezone (`"Z"`, `"+"`, `"-"`, what else?).


Thanks both for the prompt reply! I don't have a copy of the spec myself either - for the timezone suffix, I have based my previous comment on [the Wikipedia entry](https://en.wikipedia.org/wiki/ISO_8601#Time_zone_designators), which seems to hint at the following designators being allowed:
```
<time>Z
<time>±hh:mm
<time>±hhmm
<time>±hh
```
I also use this WP page, but it doesn't show much about milli/microseconds.