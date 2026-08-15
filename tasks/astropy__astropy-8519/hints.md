For the record, what are the Python, Astropy, and Numpy versions used?
Sorry about that!

python 3.6.6
numpy 1.14.5
astropy 3.0.3
@mhvk ?
@parejkoj - this behaviour is as expected: if you add two magnitudes with a unit, you are effectively multiplying the physical quantities and thus their units, while if you substract, you are dividing them. So, for the subtraction, the result is dimensionless and hence you get a regular `mag` output; similarly, if you look carefully at the addition, you'll see that the result has units of `mag(AB2)`, i.e., it is a magnitude of a quantity that has units of AB**2.

See also the section on [arithmetic](http://docs.astropy.org/en/latest/units/logarithmic_units.html#arithmetic-and-photometric-applications) in the documentation.

Hope this helps!
Yes, I'm an idiot. Classic PEBCAK. In my case, `color` is a dimension less magnitude (duh!), so the code should have read:

```
color = 10*u.mag
flux = 10000
fluxMag = (flux*u.nJy).to(u.ABmag)
diff = fluxMag - color
print(color, fluxMag, diff)
print(diff.to(u.nJy))
```

I don't normally think of magnitudes as having units, but AB magnitudes absolutely do. I wonder if the resulting error message could make this more obvious for the slower among us (like me)?
OK, no worries - I've certainly done similarly...

On the error message: I guess you are right, within the `Magnitude` (or perhaps `LogQuantity` class) error path we could special-case the dimensionless magnitude to a regular unit case, and add something like "Did you perhaps subtract magnitudes so the unit got lost?". But I'm not quite sure what exactly it would be - PR very welcome!!
I looked into this a little bit during the coworking hour this morning, but I can't figure out where such a customized exception would live. I would suggest appending your text above to the end of the regular exception message.
Possibly would make most sense as a `try/except` around the trial to convert to a regular unit: https://github.com/astropy/astropy/blob/master/astropy/units/function/core.py#L256