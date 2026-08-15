Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/main/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

GitHub issues in the Astropy repository are used to track bug reports and feature requests; If your issue poses a question about how to use Astropy, please instead raise your question in the [Astropy Discourse user forum](https://community.openastronomy.org/c/astropy/8) and close this issue.

If you feel that this issue has not been responded to in a timely manner, please leave a comment mentioning our software support engineer @embray, or send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
@mhvk will have the answer I guess, but it seems the issue comes from the use of `precision`, which probably does not do what you expect. And should be <= 9 :

> precision: int between 0 and 9 inclusive
    Decimal precision when outputting seconds as floating point.

The interesting thing is that when precision is > 9 the results are incorrect:

```
In [52]: for p in range(15):
    ...:     print(f'{p:2d}', Time(t2, format = 'jd', precision = p).to_value('isot'))
    ...: 
 0 2022-03-24T23:13:41
 1 2022-03-24T23:13:41.4
 2 2022-03-24T23:13:41.39
 3 2022-03-24T23:13:41.391
 4 2022-03-24T23:13:41.3910
 5 2022-03-24T23:13:41.39101
 6 2022-03-24T23:13:41.391012
 7 2022-03-24T23:13:41.3910118
 8 2022-03-24T23:13:41.39101177
 9 2022-03-24T23:13:41.391011775
10 2022-03-24T23:13:41.0551352177
11 2022-03-24T23:13:41.00475373422
12 2022-03-24T23:13:41.-00284414132
13 2022-03-24T23:13:41.0000514624247
14 2022-03-24T23:13:41.00000108094123
```

To get a better precision you can use `.to_value('jd', 'long')`: (and the weird results with `precision > 9` remain)

```
In [53]: t2 = t1.to_value('jd', 'long'); t2
Out[53]: 2459663.4678401735996

In [54]: for p in range(15):
    ...:     print(f'{p:2d}', Time(t2, format = 'jd', precision = p).to_value('isot'))
    ...: 
 0 2022-03-24T23:13:41
 1 2022-03-24T23:13:41.4
 2 2022-03-24T23:13:41.39
 3 2022-03-24T23:13:41.391
 4 2022-03-24T23:13:41.3910
 5 2022-03-24T23:13:41.39100
 6 2022-03-24T23:13:41.390999
 7 2022-03-24T23:13:41.3909990
 8 2022-03-24T23:13:41.39099901
 9 2022-03-24T23:13:41.390999005
10 2022-03-24T23:13:41.0551334172
11 2022-03-24T23:13:41.00475357898
12 2022-03-24T23:13:41.-00284404844
13 2022-03-24T23:13:41.0000514607441
14 2022-03-24T23:13:41.00000108090593
```
`astropy.time.Time` uses two float 64 to obtain very high precision, from the docs:

> All time manipulations and arithmetic operations are done internally using two 64-bit floats to represent time. Floating point algorithms from [1](https://docs.astropy.org/en/stable/time/index.html#id2) are used so that the [Time](https://docs.astropy.org/en/stable/api/astropy.time.Time.html#astropy.time.Time) object maintains sub-nanosecond precision over times spanning the age of the universe.

https://docs.astropy.org/en/stable/time/index.html

By doing `t1.to_value('jd')` you combine the two floats into a single float, loosing precision. However, the difference should not be 2 seconds, rather in the microsecond range.

When I leave out the precision argument or setting it to 9 for nanosecond precision, I get a difference of 12µs when going through the single jd float, which is expected:

```
from astropy.time import Time
import astropy.units as u


isot = '2022-03-24T23:13:41.390999'

t1 = Time(isot, format = 'isot', precision=9)
jd = t1.to_value('jd')
t2 = Time(jd, format='jd', precision=9)

print(f"Original:       {t1.isot}")
print(f"Converted back: {t2.isot}")
print(f"Difference:     {(t2 - t1).to(u.us):.2f}")

t3 = Time(t1.jd1, t1.jd2, format='jd', precision=9)
print(f"Using jd1+jd2:  {t3.isot}")
print(f"Difference:     {(t3 - t1).to(u.ns):.2f}")
```

prints:

```
Original:       2022-03-24T23:13:41.390999000
Converted back: 2022-03-24T23:13:41.391011775
Difference:     12.77 us
Using jd1+jd2:  2022-03-24T23:13:41.390999000
Difference:     0.00 ns
```
Thank you for your answers.

do they are a way to have access to this two floats? if i use jd tranformation it's because it's more easy for me to manipulate numbers. 
@antoinech13 See my example, it accesses `t1.jd1` and `t1.jd2`.
oh yes thank you.
Probably we should keep this open to address the issue with precsion > 9 that @saimn found?
sorry. yes indeed
Hello, I'm not familiar with this repository, but from my quick skimming it seems that using a precision outside of the range 0-9 (inclusive) is intended to trigger an exception. (see [here](https://github.com/astropy/astropy/blob/main/astropy/time/core.py#L610-L611), note that this line is part of the `TimeBase` class which `Time` inherits from). Though someone more familiar with the repository can correct me if I'm wrong.

Edit:
It seems the exception was only written for the setter and not for the case where `Time()` is initialized with the precision. Thus:
```
>>> from astropy.time import Time
>>> t1 = Time(123, fromat="jd")
>>> t1.precision = 10
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/home/brett/env/lib/python3.8/site-packages/astropy/time/core.py", line 610, in precision
    raise ValueError('precision attribute must be an int between '
ValueError: precision attribute must be an int between 0 and 9
```
produces the exception, but 
```
>>> t2 = Time(123, format="jd", precision=10)
>>> 
```
does not.

@saimn - good catch on the precision issue, this is not expected but seems to be the cause of the original problem.

This precision is just being passed straight through to ERFA, which clearly is not doing any validation on that value. It looks like giving a value > 9 actually causes a bug in the output, yikes.
FYI @antoinech13 - the `precision` argument only impacts the precision of the seconds output in string formats like `isot`. So setting the precision for a `jd` format `Time` object is generally not necessary.
@taldcroft - I looked and indeed there is no specific check in https://github.com/liberfa/erfa/blob/master/src/d2tf.c, though the comment notes:
```
**  2) The largest positive useful value for ndp is determined by the
**     size of days, the format of double on the target platform, and
**     the risk of overflowing ihmsf[3].  On a typical platform, for
**     days up to 1.0, the available floating-point precision might
**     correspond to ndp=12.  However, the practical limit is typically
**     ndp=9, set by the capacity of a 32-bit int, or ndp=4 if int is
**     only 16 bits.
```
This is actually a bit misleading, since the fraction of the second is stored in a 32-bit int, so it cannot possibly store more than 9 digits. Indeed,
```
In [31]: from erfa import d2tf

In [32]: d2tf(9, 1-2**-47)
Out[32]: (b'+', (23, 59, 59, 999999999))

In [33]: d2tf(10, 1-2**-47)
Out[33]: (b'+', (23, 59, 59, 1410065407))

In [34]: np.int32('9'*10)
Out[34]: 1410065407

In [36]: np.int32('9'*9)
Out[36]: 999999999
```
As for how to fix this, right now we do check `precision` as a property, but not on input:
```
In [42]: t = Time('J2000')

In [43]: t = Time('J2000', precision=10)

In [44]: t.precision
Out[44]: 10

In [45]: t.precision = 10
---------------------------------------------------------------------------
ValueError                                Traceback (most recent call last)
<ipython-input-45-59f84a57d617> in <module>
----> 1 t.precision = 10

/usr/lib/python3/dist-packages/astropy/time/core.py in precision(self, val)
    608         del self.cache
    609         if not isinstance(val, int) or val < 0 or val > 9:
--> 610             raise ValueError('precision attribute must be an int between '
    611                              '0 and 9')
    612         self._time.precision = val

ValueError: precision attribute must be an int between 0 and 9
```
Seems reasonable to check on input as well.