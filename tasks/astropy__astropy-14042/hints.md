This should be relatively straightforward: add a special case to `_generate_unit_names` in `units.format.fits` - main annoyance of course is tests, including actually using the value for, say, a conversion to `AltAz` or so (where temperature is actually used).
The question is what is the correct symbol? Is there any precedent? because it cannot be `°C`, as `°` is not in ASCII.
@maxnoe - ideally, we stick with whatever actually is used in the wild. Do you have examples of FITS files that have temperatures in C?
We have files that use `deg C`, which is parsed by astropy as degree * Coulomb ....
I asked the fits support office for guidance on this
I think we should be able to special-case that. After all, `deg * C` does not make much sense... Though, really, spaces in the units is pretty bad form!
Yes, I'm not saying that that is standard conform, it's certainly not.
I received the following answer:

> Many astronomical observatories record the ambient air temperature or the detector temperature in their FITS data files and I think it is safe to say that most of them use units of Celsius degrees (which is more understandable to most people) rather than pedantically following the recommendation in the FITS Standard to convert to units of Kelvin.  When recording the temperature value in a FITS header keyword they often use a units string of “deg C” or sometimes “Celsius” as in
>
> `CCDTEMP =                18.5 / [deg C] detector temperature in degrees Celsius`
> or
> `CCDTEMP =                18.5 / [Celsius] detector temperature in degrees Celsius`
>
> Hope this helps,

So according to this, we should probably add support for `Celsius` and `deg C` and use `Celsius` in our own output as it is not ambiguous?
Sounds good!