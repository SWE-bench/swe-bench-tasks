Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/main/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

GitHub issues in the Astropy repository are used to track bug reports and feature requests; If your issue poses a question about how to use Astropy, please instead raise your question in the [Astropy Discourse user forum](https://community.openastronomy.org/c/astropy/8) and close this issue.

If you feel that this issue has not been responded to in a timely manner, please send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
Hello! Can you please try with astropy 5.2.1 and also actually post what you see in the printouts, just so when someone tries to reproduce this, they can compare? Thank you.
It is still a problem in astropy5.3.dev756+gc0a24c1dc
Here is the printout :
```
# print(epochs,"\n")
ref_epoch
yr
---------
   2016.0
   2016.0
   2016.0
   2016.0
   2016.0
   2016.0 

# print("epochs is instance of MaskedColumn:", isinstance(epochs, astropy.table.column.MaskedColumn),"\n")
epochs is instance of MaskedColumn: True 

# print("epochs in jyear: ",Time(epochs,format='jyear'),"\n")
epochs in jyear:  [2016. 2016. 2016. 2016. 2016. 2016.] 

# print("epochs in decimalyear: ",Time(epochs,format='decimalyear'))
erfa/core.py:154: ErfaWarning: ERFA function "dtf2d" yielded 6 of "dubious year (Note 6)"
  warnings.warn('ERFA function "{}" yielded {}'.format(func_name, wmsg),
erfa/core.py:154: ErfaWarning: ERFA function "utctai" yielded 6 of "dubious year (Note 3)"
  warnings.warn('ERFA function "{}" yielded {}'.format(func_name, wmsg),
erfa/core.py:154: ErfaWarning: ERFA function "taiutc" yielded 6 of "dubious year (Note 4)"
  warnings.warn('ERFA function "{}" yielded {}'.format(func_name, wmsg),
erfa/core.py:154: ErfaWarning: ERFA function "d2dtf" yielded 6 of "dubious year (Note 5)"
  warnings.warn('ERFA function "{}" yielded {}'.format(func_name, wmsg),
epochs in decimalyear:  [736344. 736344. 736344. 736344. 736344. 736344.]

# print("epoch2 in jyear=", epoch2)
epoch2 in jyear= 2016.0
# print("epoch3 in decimalyear=", epoch3)
epoch3 in decimalyear= 2016.0
```
 
If you choose a particular element of the epochs MaskedColumn, it's OK, for example adding the following to the end of the program, it's OK, the result is "2016.0":

`print(Time(epochs[5],format='decimalyear')
`
@fsc137-cfa - Thanks for the report! And the example is helpful, but I don't think it has anything to do with `MaskedColumn`, but rather with passing in numbers with a unit (the reason it works for a single element of a `MaskedColumn` is that then one has lost the unit). Indeed, a minimal example is:
```
from astropy.time import Time
import astropy.units as u

Time(2016.*u.yr, format='decimalyear')
/usr/lib/python3/dist-packages/erfa/core.py:154: ErfaWarning: ERFA function "dtf2d" yielded 1 of "dubious year (Note 6)"
  warnings.warn('ERFA function "{}" yielded {}'.format(func_name, wmsg),
/usr/lib/python3/dist-packages/erfa/core.py:154: ErfaWarning: ERFA function "utctai" yielded 1 of "dubious year (Note 3)"
  warnings.warn('ERFA function "{}" yielded {}'.format(func_name, wmsg),
/usr/lib/python3/dist-packages/erfa/core.py:154: ErfaWarning: ERFA function "taiutc" yielded 1 of "dubious year (Note 4)"
  warnings.warn('ERFA function "{}" yielded {}'.format(func_name, wmsg),
/usr/lib/python3/dist-packages/erfa/core.py:154: ErfaWarning: ERFA function "d2dtf" yielded 1 of "dubious year (Note 5)"
  warnings.warn('ERFA function "{}" yielded {}'.format(func_name, wmsg),

<Time object: scale='utc' format='decimalyear' value=736344.0>
```
The bug here is that the default "unit" for time input is days, so the number in years first gets converted to days and then is interpreted as years: `2016*365.25=736344`.

The standard unit conversion also indicates a problem with the in principle simple solution of just setting `TimeDecimalYear.unit = u.yr`. With that, any conversion will assume *julian years* of `365.25` days, which would be OK for `jyear` but is inconsistent with `TimeDecimalYear`, as for that format the fraction can get multiplied by either 365 or 366 to infer month, day, and time.

Overall, my tendency would be to just forbid the use of anything with a unit for `decimalyear` just like we do for `bjear` (or *maybe* allow `u.yr` but no other time unit, as they are ambiguous).

Let me ping @taldcroft to see what he thinks, since I think he was more involved than I was in the implementation of `TimeDecimalYear`.

p.s. To further clarify the difference between `jyear` and `decimalyear`, `jyear` strictly takes years as lasting `365.25` days, with a zero point at J2000:
```
In [28]: Time([2000, 2001], format='jyear').isot
Out[28]: array(['2000-01-01T12:00:00.000', '2000-12-31T18:00:00.000'], dtype='<U23')

In [29]: Time([2000, 2001], format='decimalyear').isot
Out[29]: array(['2000-01-01T00:00:00.000', '2001-01-01T00:00:00.000'], dtype='<U23')
```
p.s. For the GAIA query that likely led you to raise this issue, please be sure to check what `ref_epoch` actually means. Most likely `jyear` is the correct format to use!
My program (copied in part from elsewhere) originally used jyear, but I was
trying to figure out from the documentation what is the difference between
decimalyear and jyear, so I tried the program both ways, leading to trying
out decimalyear and this bug report.

I still don't know the difference between jyear and decimalyear.
"jyear" suggests to me something like the JDN divided by 365.2425... , not
just a decimal expression of a year, although clearly it acts that way.
I would think that "decimalyear" would be what you would want when just
expressing a time in years as a real (decimal) number.
That's how epochs are usually expressed, since a tenth or a hundredth of a
year is all the accuracy one needs to calculate precession, proper motion,
etc.

On Fri, Mar 17, 2023 at 7:11 PM Marten van Kerkwijk <
***@***.***> wrote:

> p.s. For the GAIA query that likely led you to raise this issue, please be
> sure to check what ref_epoch actually means. Most likely jyear is the
> correct format to use!
>
> —
> Reply to this email directly, view it on GitHub
> <https://github.com/astropy/astropy/issues/14541#issuecomment-1474499729>,
> or unsubscribe
> <https://github.com/notifications/unsubscribe-auth/ATGPZCTLLWL7AGV55B33E7DW4TVRTANCNFSM6AAAAAAV6ALBTQ>
> .
> You are receiving this because you were mentioned.Message ID:
> ***@***.***>
>


-- 
*Antony A. Stark*
*Senior Astronomer*

*Center for Astrophysics | Harvard & Smithsonian*

*60 Garden Street | MS 42 | Cambridge, MA 02138*

epochs in astronomy are these days all in `J2000` (i.e., `format='jyear'`), which is just the number of Julian years (of 365.25 days) around 2000; I'm near-certain this is true for GAIA too. (Before, it was `B1950` or `byear`). The `decimalyear` format was added because it is used in some places, but as far as I know not by anything serious for astrometry. as the interpretation of the fraction depends on whether a year is a leap year or not.
p.s. `365.2425` is what one would get if a Gregorian year were used! Caesar didn't bother with the details for his [Julian calendar](https://en.wikipedia.org/wiki/Julian_calendar) too much...
So looks like there is no bug and this issue can be closed? Thanks!
There is a bug, in that the units are used if a `Quantity` is passed into `decimalyear` -- I think the solution is to explicitly forbid having units for this class, since the scale of the unit `year` is different than that assumed here (like for `byear`).
I'd like to see the documentation define both "decimalyear" and "jyear",
and the differences between them.
I am fully aware of how time and dates are used in astronomy, yet I am
confused.

On Mon, Mar 20, 2023 at 8:54 AM Marten van Kerkwijk <
***@***.***> wrote:

> There is a bug, in that the units are used if a Quantity is passed into
> decimalyear -- I think the solution is to explicitly forbid having units
> for this class, since the scale of the unit year is different than that
> assumed here (like for byear).
>
> —
> Reply to this email directly, view it on GitHub
> <https://github.com/astropy/astropy/issues/14541#issuecomment-1476181698>,
> or unsubscribe
> <https://github.com/notifications/unsubscribe-auth/ATGPZCXHSDCHZTS34DTI3P3W5BHOTANCNFSM6AAAAAAV6ALBTQ>
> .
> You are receiving this because you were mentioned.Message ID:
> ***@***.***>
>


-- 
*Antony A. Stark*
*Senior Astronomer*

*Center for Astrophysics | Harvard & Smithsonian*

*60 Garden Street | MS 42 | Cambridge, MA 02138*

Agreed that better documentation would help, as currently, the docs are indeed rather sparse: https://docs.astropy.org/en/latest/time/index.html#time-format just gives some formats, which I guess could at least have the same time instance as an example (maybe as an extra column). And then there could be more detail in the actual class docstrings
https://docs.astropy.org/en/latest/api/astropy.time.TimeJulianEpoch.html#astropy.time.TimeJulianEpoch
https://docs.astropy.org/en/latest/api/astropy.time.TimeDecimalYear.html#astropy.time.TimeDecimalYear

Would you be interested in making a PR?

Of course, this is separate from the bug you uncovered... So, maybe the first thing would be to raise a new issue, just focussed on documentation.