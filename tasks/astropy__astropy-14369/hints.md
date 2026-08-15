Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/main/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

GitHub issues in the Astropy repository are used to track bug reports and feature requests; If your issue poses a question about how to use Astropy, please instead raise your question in the [Astropy Discourse user forum](https://community.openastronomy.org/c/astropy/8) and close this issue.

If you feel that this issue has not been responded to in a timely manner, please send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
Hmm, can't be from `units` proper because seems to parse correctly like this and still the same even if I do `u.add_enabled_units('cds')` with astropy 5.3.dev.

```python
>>> from astropy import units as u
>>> u.Unit('10+3J/m/s/kpc2')
WARNING: UnitsWarning: '10+3J/m/s/kpc2' contains multiple slashes, which is discouraged by the FITS standard [astropy.units.format.generic]
Unit("1000 J / (kpc2 m s)")
>>> u.Unit('10-7J/s/kpc2')
WARNING: UnitsWarning: '10-7J/s/kpc2' contains multiple slashes, which is discouraged by the FITS standard [astropy.units.format.generic]
Unit("1e-07 J / (kpc2 s)")
>>> u.Unit('10-7J/s/kpc2').to_string()
WARNING: UnitsWarning: '10-7J/s/kpc2' contains multiple slashes, which is discouraged by the FITS standard [astropy.units.format.generic]
'1e-07 J / (kpc2 s)'
```
Yes, `units` does this properly (for my particular case I did a separate conversion using that). 
It does seem a bug in the CDS format parser. While as @pllim noted, the regular one parses fine, the CDS one does not:
```
In [3]: u.Unit('10+3J/m/s/kpc2', format='cds')
Out[3]: Unit("1000 J s / (kpc2 m)")
```
There must be something fishy in the parser (`astropy/units/format/cds.py`).