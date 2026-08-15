Additional examples that *do* work:
```python
Unit('10**+17 erg/(cm2 s Angstrom)', format='fits')
Unit('10^+17 erg/(cm2 s Angstrom)', format='fits')
```
It seems that currently the sign is always required for the `**` and `^`, though it should not:

> The final units string is the compound string, or a compound of compounds, preceded by an optional numeric multiplier of the form 10**k, 10ˆk, or 10±k where k is an integer, optionally surrounded by parentheses with the sign character required in the third form in the absence of parentheses.

> The power may be a simple integer, with or without sign, optionally surrounded by parentheses.
The place to look in the parser is https://github.com/astropy/astropy/blob/master/astropy/units/format/generic.py#L274, and I think all it would take is replace `signed_int` by `numeric_power` (but don't have time to try myself right now).
I tried two possibilities:

1. Simply replace `UINT power signed_int` with `UINT power numeric_power`.  That broke valid expressions like `10**+2`.
2. Add `UINT power numeric_power` in addition to `UINT power signed_int`.  That did not make `10**2` valid.
I think it may have to be `UINT power SIGN numeric_power` - sign can be empty.
Unfortunately that didn't help either, it broke the existing valid expressions and did not make `10**2` valid.
Another odd thing. In the traceback of the test failures I can see [p_factor_int()](https://github.com/astropy/astropy/blob/master/astropy/units/format/generic.py#L252) being called but not [p_factor_fits()](https://github.com/astropy/astropy/blob/master/astropy/units/format/generic.py#L274).
@weaverba137 - that last thing at least is probably not odd: the test fails because in its current form `p_factor_fits()` does not match the string.

On why my suggestions do not work: I'm a bit at a loss and will try to investigate, though I'm not quite sure when...