@evertrol - I think the best strategy here is to raise an exception.  The point is that the astropy string subformats like `date` are documented to be symmetric, so that if you put in `2017-08-24.25` then it parses that and the representation would then be something like `2017-08-24.250` (with a default precision of 3 digits).  So this is inventing a whole new class of time formats.  Likewise the current API does not document being able to include fractional days, so it is reasonable to keep the API the same and just raise an exception.

I guess it is fair to ask where "it is used".  Are there officially sanctioned (institutional) uses of this or just informal use?

As for implementation, this would go in the `parse_string` method in `TimeString`.  Unfortunately the current code makes it a difficult to implement a rock-solid way of detecting a problem.  A good start that will detect most problems is basically checking that the inferred date format is in a list of formats that include seconds, e.g. `('date_hms', 'longdate_hms')`.  The problem is with user-defined formats... but perfect is the enemy of good.
I think a match against
```python
re.match(r'\d{4}-\d{1,2}-\d{1,2}\.\d+$', val)
```
may work (followed by a `ValueError`). No other date formats that spring to my mind match that. But I may have missed how much flexibility there is for a user to define a format.

As to where it is used: I very much doubt this is a sanctioned format, and I see it mostly used in telegrams and circulars, depending on the group that submits it. A recent example is [ATel 10652](http://www.astronomerstelegram.org/?read=10652).
So the danger for errors may mostly be when people copy-paste such a date into a `Time` object, and not notice the resulting incorrect time (e.g., when subtracting another `Time` directly from it).

Strange that a somewhat-official telegram would use this non-format.  Well maybe it's worth allowing this on input.  Sigh.

One way that might work and be relatively low-impact is to change this [loop here](https://github.com/astropy/astropy/blob/b6e291779ea76b7e4710df90e1800e5dfefc52e8/astropy/time/formats.py#L713) to include the format name, i.e.:
```
for format_name, strptime_fmt_or_regex, _ in subfmts:
```
Then later in the loop (at the `# add fractional seconds` bit), if the format_name is `date` then apply the fractional part as a day.  If it is a format that supports fractional seconds, then apply as seconds.  Otherwise if `format_name` is one of the defined core astropy format names (but not in the previous two categories) then raise an exception.  This would catch input like `2016-01-01 10:10.25`.  However, if the format name is something custom from a user then just continue the current behavior of the code.

Anyway this is just brainstorming for something simple.  One can imagine higher-impact, more robust solutions, but it isn't totally clear we want to go there for this corner case.
One interesting edge case is where a user actually defines a fractional hour or minute format themselves. For example:
```python
class FracHour(TimeString):
    subfmts = (
        ('fh', 
         (r'(?P<year>\d{4})-(?P<mon>\d{1,2})-(?P<mday>\d{1,2}) '
          r'(?P<hour>\d{1,2}(\.\d*))'), 
         '{year:d}-{mon:02d}-{day:02d}T{hour:05.2f}'),
    )
```
This will raise a `ValueError: Input values did not match the format class fh` even with correct input: `Time('1999-01-01 5.5', format='fh')`.

I guess that's correct though: Astropy can't go out of its way to infer when a fraction belongs to a day, hour, minute or second (it could, but the rewrite would be quite horrendous, and not worth the effort).

<hr>

I've now gone the route of allowing fractional days for both `'date'` and `'yday'` formats, allowing fractional seconds for `...endswith('hms')` and otherwise skip to the next sub-format.
This has caught me out a few times as well. The Minor Planet Center (MPC) uses a specific format for observations of asteroids and comets:
`'2020 08 15.59280'`
Which isn't understood by astropy.time.Time, but if spaces are replaced with dashes, it gives:
```
Time('2020 08 15.59280'.replace(' ', '-'))
<Time object: scale='utc' format='iso' value=2020-08-15 00:00:00.593>
```
whereas it should in fact convert to
`'2020-08-15 14:13:37.920'`
The best solution I have found is to add the decimal after converting to a Time object:
```
>>> Time('2020 08 15'.replace(' ', '-'))+'.59280'
<Time object: scale='utc' format='iso' value=2020-08-15 14:13:37.920>
```
But this is somewhat clunky. It would be nice if "mpc" (or "mpc_obs80") could be added to the allowed formats, so that I'd just need to remember to add the correct format specifier instead of changing spaces to dashes and adding the decimal day after the conversion to a Time object. 

(I work at the MPC, and my research also uses MPC-formatted files extensively, so I often come across this problem and finally decided to go raise an issue about it; I found several already open, so I just added to this one.)
Sorry there hasn't been any progress on this issue. I'll go back to my original point that `"2020-08-15.59280"` is unequivocally not an ISO8601-formatted date, so passing in this string should currently raise an exception. In other words there is no current Time format which should match that string. The fact that the ISO format matches is a bug in the parser.

An enhancement could be to define a new Time format which does match that like `date_fracday` or something. Some of my original discussion that alluded to making a new ISO time subformat for this case was off base.