+1

This would not be too difficult to implement, but as I don't see myself having time soon (I really want to avoid `datetime` if at all possible...), just what I think would be needed:
1. Make a new `TimeDeltaDatetime(TimeDeltaFormat, TimeUnique)` class in `astropy.time.formats` (can add near the very end of the file), with a setup similar to that of `TimeDatetime` (ie., `_check_val_type`, `set_jds`, and `to_value` methods, plus the definition of the `value` property). Its name can be 'datetime', I think, since it is obvious from context it is a delta (similarly, the name of `TimeDeltaJD` is just 'jd').
2. Write a new `to_datetime` function in `TimeDelta` which overrides the one from `Time` (I think it is OK to use the same name, since we're producing just the delta version of the `datetime` object.
3. Write test cases for scalar and array-valued input and output.
4. Add a line to the available `TimeDelta` formats in `docs/time/index.rst`.

I don't know enough about the numpy versions to comment usefully, but ideally the `TimeDatetime` and new `TimeDeltaDatetime` would be adjusted to be able to deal with those.

EDIT: actually, the numpy versions may need their own format classes, since one would want to be able to convert `Time` objects to them by just doing `t.datetime64` or so. Most likely, these new classes could just be rather simple subclasses of `TimeDatetime` and `TimeDeltaDatetime`.

p.s. I changed the title to be a bit more general, as I think just reusing `to_datetime` is slightly better than making a new `to_timedelta`. Note that, in principle, one does not have to define a `to_*` method at all: the moment a new `TimeDeltaFormat` is defined, `TimeDelta` instances will get a property with the same name that can be used for conversion. The only reason `to_timedelta` exists is to make it possible to pass on a timezone.

it is indeed quite confusing to have a method offered that results in an error instead of a warning/"Not Implemented" message, without the user doing anything syntactically wrong (while the initiated user might realise that a TimeDelta object shouldn't go to datetime but timedelta:

```python
t1 = Time("2008-01-15")
t2 = Time("2017-06-15")
dt = t2 - t1
dt.to_datetime()

---------------------------------------------------------------------------
ValueError                                Traceback (most recent call last)
<ipython-input-18-963672c7c2b3> in <module>()
      5 dt = t2 - t1
      6 
----> 7 dt.to_datetime()

~/miniconda3/envs/stable/lib/python3.6/site-packages/astropy/time/core.py in to_datetime(self, timezone)
   1472 
   1473     def to_datetime(self, timezone=None):
-> 1474         tm = self.replicate(format='datetime')
   1475         return tm._shaped_like_input(tm._time.to_value(timezone))
   1476 

~/miniconda3/envs/stable/lib/python3.6/site-packages/astropy/time/core.py in replicate(self, *args, **kwargs)
   1548 
   1549     def replicate(self, *args, **kwargs):
-> 1550         out = super(TimeDelta, self).replicate(*args, **kwargs)
   1551         out.SCALES = self.SCALES
   1552         return out

~/miniconda3/envs/stable/lib/python3.6/site-packages/astropy/time/core.py in replicate(self, format, copy)
    831             Replica of this object
    832         """
--> 833         return self._apply('copy' if copy else 'replicate', format=format)
    834 
    835     def _apply(self, method, *args, **kwargs):

~/miniconda3/envs/stable/lib/python3.6/site-packages/astropy/time/core.py in _apply(self, method, *args, **kwargs)
    917         if new_format not in tm.FORMATS:
    918             raise ValueError('format must be one of {0}'
--> 919                              .format(list(tm.FORMATS)))
    920 
    921         NewFormat = tm.FORMATS[new_format]

ValueError: format must be one of ['sec', 'jd']
```
This feature request is really waiting on someone taking the time to implement it...  Probably best if that were someone who actually used `datetime` and `timedelta` -- PRs always welcome!
I would like to work on this issue.

On a side note, if I implement (I don't know if it's possible or not) `TimeDelta` format classes for milliseconds and weeks (like `datetime.timedelta`) would you accept? @mhvk 
@vn-ki - all `TimeDelta` formats internally store their times in days. I think they could most usefully be modeled on the regular `TimeDateTime` class.

I should add, as I wrote above, I also do not use `datetime` myself at all, so have little interest or specific experience; the summary of what one should do that I wrote above is about all I can easily contribute. Since I don't foresee having time to supervise beyond that, please do think carefully whether you think you know enough before starting this. (Cc @taldcroft, in case he is in a better position.)
@mhvk can I ask, out of interest, how you do time difference calculations without using datetime?
That is what the `TimeDelta` class is for! I.e., I just substract two `Time` instances and the magic of numpy broadcasting even means arrays are done right.
@michaelaye - certainly agreed that the current situation is indeed confusing, so having the `TimeDelta.to_datetime()` method at least raise `NotImplemented` (with some useful message) would be the first trivial thing to do.

@vn-ki - like @mhvk I don't actually ever use `datetime` by choice, but if you come up with a PR then I'll be happy to review it.  My initial idea would be overriding the `to_datetime`, where in this case `datetime` means the `datetime` package, not the object.  But other suggestions welcome.
@mhvk Somehow its existence escaped me. ;) I even don't remember what my use case was that I copied above. I will make sure to use TimeDelta from now on! :)