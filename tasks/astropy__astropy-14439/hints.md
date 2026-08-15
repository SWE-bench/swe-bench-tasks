Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/main/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

GitHub issues in the Astropy repository are used to track bug reports and feature requests; If your issue poses a question about how to use Astropy, please instead raise your question in the [Astropy Discourse user forum](https://community.openastronomy.org/c/astropy/8) and close this issue.

If you feel that this issue has not been responded to in a timely manner, please leave a comment mentioning our software support engineer @embray, or send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
Err what does the FITS standards paper(s) have to say about this?
https://fits.gsfc.nasa.gov/standard40/fits_standard40aa-le.pdf This one mentions 'Jy/beam' as an example. But the unit is not defined anywhere in the document.

`beam-1 Jy` is a valid FITS unit. I think the `-1` is preferred by Astropy because using more than one `/` is discouraged, but @mhvk has probably more to say about this.
Hmm, that may be valid but I agree it is not the most readable! It is also a bit odd that the generic format, i.e., with `(u.Jy/u.beam).to_string()`, one gets 'Jy / beam' .

@spectram - would 'Jy beam-1' be sufficiently better? I think that might be relatively straightforward to implement, and at least easier than trying to work with `/`. Though I should add that I have not actually looked at the code in `units/format/fits.py`, nor do I see much time for it in the near future... But a PR that solves this more or less generally would certainly be welcome! 
Writing `Jy beam-1' would already make infinitely more sense. It may be good to point out that all major radio observatories/software packages use Jy/beam as unit so in principle that is the preferred way for now.
The IAU has Jy as recognised unit, but does not stipulate anything about Jy/beam (https://www.iau.org/publications/proceedings_rules/units/). Beam is mentioned as a 'miscellaneous unit' table 4 in the FITS document https://fits.gsfc.nasa.gov/standard40/fits_standard40aa-le.pdf
Hey all,

I just wanted to bump this thread, if possible. Astropy does seem to be the outlier here since (as already mentioned) CASA, wsclean, YandaSoft, etc. all produce images with
```
BUNIT   = 'Jy/beam '           / Brightness (pixel) unit
```
Looking at the [WCS papers](https://www.atnf.csiro.au/people/mcalabre/WCS/wcs.pdf), notably Table 3:
![image](https://user-images.githubusercontent.com/9074527/218953706-e0914d74-1e91-4586-891f-b88a56c554dc.png)
a number of string-denoted operations are supported. So the FITS standard could be any of:
```
Jy beam**-1
Jy beam^-1
Jy/beam
```
It would be really nice to have the last option be the default. This would also help the downstream packages, as mentioned in the OP.

EDIT: Reading further down gives some explicit examples:

> A unit raised to a power is indicated by
> the unit string followed, with no intervening blanks, by the optional 
> symbols `**` or `ˆ` followed by the power given as a nu-
> meric expression, called expr in Table 3. The power may be a
> simple integer, with or without sign, optionally surrounded by
> parentheses. It may also be a decimal number (e.g., 1.5, .5) or
> a ratio of two integers (e.g. 7/9), with or without sign, which
> are always surrounded by parentheses. Thus meters squared is
> indicated by `m**(2)`, `m**+2`, `m+2`, `m2`, `mˆ2`, `mˆ(+2)`, etc. and
> per meter cubed is indicated by `m**-3`, `m-3`, `mˆ(-3)`, `/m3`,
> and so forth. Meters to the three halves may be indicated
> by `m(1.5)`, `mˆ(1.5)`, `m**(1.5)`, `m(3/2)`, `m**(3/2)`, and
> `mˆ(3/2)`, but not by `mˆ3/2` or `m1.5`.
> Note that functions such as log actually require dimen-
> sionless arguments, so, by `log(Hz)`, for example, we actually
> mean `log(x/1Hz)`. The final string to be given as the value
> of CUNIT ia is the compound string, or a compound of com-
> pounds, preceded by an optional numeric multiplier of the form
> `10**k`, `10ˆk`, or `10±k` where `k` is an integer, optionally sur-
> rounded by parentheses with the sign character required in the
> third form in the absence of parentheses. FITS writers are en-
> couraged to use the numeric multiplier only when the available
> standard scale factors of Table 4 will not suffice. Parentheses
> are used for symbol grouping and are strongly recommended
> whenever the order of operations might be subject to misin-
> terpretation. A blank character implies multiplication which
> can also be conveyed explicitly with an asterisk or a period.
> Therefore, although blanks are allowed as symbol separators,
> their use is discouraged. Two examples are `’10**(46)erg/s’`
> and `’sqrt(erg/pixel/s/GHz)’`. Note that case is signif-
> icant throughout. The IAU style manual forbids the use of
> more than one solidus (`/`) character in a units string. In the
> present conventions, normal mathematical precedence rules are
> assumed to apply, and we, therefore, allow more than one
> solidus. However, authors might wish to consider, for exam-
> ple, `’sqrt(erg/(pixel.s.GHz))’` instead of the form given
> previously.

So `beam-1 Jy`, `Jy beam-1` and `Jy/beam` are all valid in FITS. But, I've found in practice reading from the former yields `UnreconizedUnit(beam-1 Jy)`. I would argue that the latter is the most readable (subjective, yes). But it has also become the de-facto standard.
Since CASA is mentioned, I am obligated to ping @keflavich . 😸 
Yeah I'll put my weight behind the rest here: `Jy/beam` is the most readable, followed by `Jy beam^(-1)` and its variants.  We read the unit as "Janksys per beam" out loud (and in my head).

`beam` is itself a horrendous unit that is incredibly useful, which is likely why it's overlooked in IAU rules.

I think we have broad consensus here that *some* alternative that puts inverse `beam` after `Jy` is desired, so we just need an implementation.
To help get this rolling:
`beam` comes before `Jy` because of this alphabetization:
https://github.com/astropy/astropy/blob/main/astropy/units/format/generic.py#L633

Past that, I'm not sure what the preferred way is to fix this. I don't see an obvious place to inject specific exceptions to this rule.
Note that `generic` actually does this right (because positive powers come first, I think. 

Anyway, I think there is general consensus that ideally it be `Jy / beam` and at the very least `Jy beam-1`. It all boils down to the question who has time to actually implement it...