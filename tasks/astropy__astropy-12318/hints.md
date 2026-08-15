I forgot who added that part of `BlackBody`. It was either @karllark or @astrofrog .
There are several problems here:

1. In `BlackBody.evaluate()`, there is an `if` statement that handles two special cases: either scale is dimensionless, and multiplies the original blackbody surface brightness, or `scale` has units that are compatible with surface brightness, and replaces the original surface brightness. This check is broken, because it does not correctly handle the case that `scale` has a unit, but that unit is compatible with `dimensionless_unscaled`. This is easy to fix.
2. The `BlackBody.bolometric_flux` method does not handle this special case. Again, this is easy to fix.
3. In the case that  `scale` has units that are compatible with surface brightness, it is impossible to unambiguously determine the correct multiplier in `BlackBody.bolometric_flux`, because the conversion may depend on the frequency or wavelength at which the scale was given. This might be a design flaw.

Unless I'm missing something, there is no way for this class to give an unambiguous and correct value of the bolometric flux, unless `scale` is dimensionless. Is that correct?
Here's another weird output from BlackBody. I _think_ it's a manifestation of the same bug, or at least it's related. I create three black bodies:

* `bb1` with a scale=1 erg / (cm2 Hz s sr)
* `bb2` with a scale=1 J / (cm2 Hz s sr)
* `bb3` with a scale=1e7 erg / (cm2 Hz s sr)

The spectra from `bb1` and `bb2` look the same, even though `bb2` should be (1 J / 1 erg) = 1e7 times as bright! And the spectrum from `bb3` looks different from `bb2`, even though 1e7 erg = 1 J.

```python
from astropy.modeling.models import BlackBody
from astropy import units as u
from matplotlib import pyplot as plt
import numpy as np

nu = np.geomspace(0.1, 10) * u.micron
bb1 = BlackBody(temperature=3000*u.K, scale=1*u.erg/(u.cm ** 2 * u.s * u.Hz * u.sr))
bb2 = BlackBody(temperature=3000*u.K, scale=1*u.J/(u.cm ** 2 * u.s * u.Hz * u.sr))
bb3 = BlackBody(temperature=3000*u.K, scale=1e7*u.erg/(u.cm ** 2 * u.s * u.Hz * u.sr))

fig, ax = plt.subplots()
ax.set_xscale('log')
ax.set_yscale('log')
ax.plot(nu.value, bb1(nu).to_value(u.erg/(u.cm ** 2 * u.s * u.Hz * u.sr)), lw=4, label='bb1')
ax.plot(nu.value, bb2(nu).to_value(u.erg/(u.cm ** 2 * u.s * u.Hz * u.sr)), label='bb2')
ax.plot(nu.value, bb3(nu).to_value(u.erg/(u.cm ** 2 * u.s * u.Hz * u.sr)), label='bb3')
ax.legend()
fig.savefig('test.png')
```

![test](https://user-images.githubusercontent.com/728407/115497738-3e2ef600-a23a-11eb-93b0-c9e358afd986.png)

This is great testing of the code.  Thanks!

I think I was the one that added this capability.  I don't have time at this point to investigate this issue in detail.  I can look at in the near(ish) future.  If someone else is motivated and has time to investigate and solve, I'm happy to cheer from the sidelines.
In pseudocode, here's what the code does with `scale`:

* If `scale` has no units, it simply multiplies a standard blackbody.
* If `scale` has units that are compatible with flux density, it splits off the value and unit. The value multiplies the standard blackbody, and the output is converted to the given unit.

So in both cases, the actual _units_ of the `scale` parameter are ignored. Only the _value_ of the `scale` parameter matters.

As nice as the spectral equivalencies are, I think it was a mistake to support a dimensionful `scale` parameter. Clearly that case is completely broken. Can we simply remove that functionality?
Beginning to think that the scale keyword should go away (in time, deprecated first of course) and docs updated to clearly show how to convert between units (flam to fnu for example) and remove sterradians.  Astropy does have great units support and the scale functionality can all be accomplished with such.  Not 100% sure yet, looking forward to seeing what others think.

The blackbody function would return in default units and scale (fnu seems like the best choice, but kinda arbitrary in the end).

If my memory is correct, the scale keyword was partially introduced to be able to reproduce the previous behavior of two backbody functions that were deprecated and have now been removed from astropy.
No, I think @astrofrog introduced scale for fitting. The functional, uh, functions that we have removed did not have scaling.
FWIW, I still have the old stuff over at https://github.com/spacetelescope/synphot_refactor/blob/master/synphot/blackbody.py . I never got around to using the new models over there. 😬 
In trying to handle support for flux units outside of the `BlackBody` model, I ran into a few issues that I'll try to summarize with an example below.

```
from astropy.modeling import models
import astropy.units as u

import numpy as np

FLAM = u.erg / (u.cm ** 2 * u.s * u.AA)
SLAM = u.erg / (u.cm ** 2 * u.s * u.AA * u.sr)

wavelengths = np.linspace(2000, 50000, 10001)*u.AA
```

Using `Scale` to handle the unit conversion fails in the forward model because the `Scale` model will not accept wavelength units as input (it seems `factor` **must** be provided in the same units as the input x-array, but we need output of `sr` for the units to cooperate).

```
m = models.BlackBody(temperature=5678*u.K, scale=1.0*SLAM) * models.Scale(factor=1.0*u.sr)
    
fluxes = m(wavelengths)
```

which gives the error: `Scale: Units of input 'x', Angstrom (length), could not be converted to required input units of sr (solid angle)`.

Using `Linear1D` with a slope of 0 and an intercept as the scaling factor (with appropriate units to convert from wavelength to `sr`) does work for the forward model, and yields correct units from the `Compound` model, but fails within fitting when calling `without_units_for_data`:

```
m = models.BlackBody(temperature=5678*u.K, scale=1.0*SLAM) * models.Linear1D(slope=0.0*u.sr/u.AA, intercept=1.0*u.sr)

fluxes = m(wavelengths)
m.without_units_for_data(x=wavelengths, y=fluxes)
```

with the error: `'sr' (solid angle) and 'erg / (Angstrom cm2 s)' (power density/spectral flux density wav) are not convertible`.  It seems to me that this error _might_ be a bug (?), and if it could be fixed, then this approach would technically work for handling the scale and unit conversions externally, but its not exactly obvious or clean from the user-perspective.

Is there another approach for handling the conversion externally to the model that works with fitting and `Compound` models?  If not, then either the `without_units_for_data` needs to work for a case like this, or I think `scale` in `BlackBody` might need to be kept and extended to support `FLAM` and `FNU` units as input to allow fluxes as output.
While I broadly like the cleanness of @karllark's approach of just saying "rescale to your hearts desire", I'm concerned that the ship has essentially sailed.  In particular, I think the following are true:
1. Plenty of other models have scale parameters, so users probably took that up conceptually already
2. In situations like `specutils` where the blackbody model is used as a tool on already-existing data, it's often useful to carry around the model *with its units*.

So to me that argues pretty clearly for "allow `scale` to have whatever units the user wants. But I see a way to "have our cake and eat it too":

1. Take the existing blackbody model, remove the `scale`, and call it `UnscaledBlackbodyModel` or something
2. Make a new `BlackbodyModel` which is a compound model using `Scale` (with `scale` as the keyword), assuming @kecnry's report that it failed can be fixed (since it sure seems like as a bug).

That way we can let people move in the direction @karllark suggested if it seems like people actually like it by telling them to use `UnscaledBlackbodyModel`, but fixing the problem with `Scale` at the same time.  

(Plan B, at least if we want something fixed for Astropy 5.0, is to just fix `scale` and have the above be a longer-term plan for maybe 5.1)
If someone else wants to do Plan B for ver5.0 as described by @eteq, that's fine with me.  I won't have time before Friday to do such.
I think that all of these proposed solutions fail to address the problem that scale units of FLAM or FNU cannot be handled unambiguously, because the reference frequency or wavelength is unspecified.
I feel the way forward on this topic is to generate a list of use cases for the use of the scale keyword and then we can figure out how to modify the current code.  These use cases can be coded up into tests.  I have to admit I'm getting a little lost in knowing what all the uses of scale.
And if all the use cases are compatible with each other.
@lpsinger - agreed.  The `bolometric_flux` method and adding support for flux units to `evaluate` are definitely related, but have slightly different considerations that make this quite difficult.  Sorry if the latter goal somewhat hijacked this issue - but I do think the solution needs to account for both (as well as the unitless "bug" in your original post).

@karllark - also agreed.  After looking into this in more detail, I think `scale` really has 2 (and perhaps eventually 3) different purposes: a _unitless_ scale to the blackbody equation, determining the output units of `evaluate` and whether it should be wrt wavelength or frequency, and possibly would also be responsible for providing `sterradians` to convert to flux units.  Separating this functionality into three separate arguments might be the simplest to implement and perhaps the clearest and might resolve the `bolometric_flux` concern, but also is clunky for the user and might be a little difficult for backwards compatibility.  Keeping it as one argument is definitely convenient, but confusing and raises issues with ambiguity in `bolometric_flux` mentioned above.
@kecnry, I'm concerned that overloading the scale to handle either a unitless value or a value with units of steradians is a footgun, because depending on the units you pass, it may or may not add a factor of pi. This is a footgun because people often think of steradians as being dimensionless.
@lpsinger (and others) - how would you feel about splitting the parameters then?  
* `scale`: **must** be unitless (or convertible to true unitless), perhaps with backwards compatibility support for SLAM and SNU units that get stripped and interpreted as `output_units`.  I think this can then be used in both `evaluate` and `bolometric_flux`.
* `solid_angle` (or similar name): which is only required when wanting the `evaluate` method to output in flux units.  If provided, you must also set a compatible unit for `output_units`.
* `output_units` (or similar name): choose whether `evaluate` will output SNU (default as it is now), SLAM, FNU, or FLAM units (with compatibility checks for the other arguments: you can't set this to SLAM or SNU and pass `solid_angle`, for example).

The downside here is that in the flux case, fitting both `scale` and `solid_angle` will be entirely degenerate, so one of the two will likely need to be held fixed.  In some use-cases where you don't care about how much of the scale belongs to which units, it might be convenient to just leave one fixed at unity and let the other absorb the full scale factor.  But the upside is that I _think_ this approach might get around the ambiguity cases you brought up?
A delta on @kecnry's suggestion to make it a bit less confusing to the user (maybe?) would be to have *3* classes, one that's just `BaseBlackbodyModel` with only the temperature (and no units), a `BlackbodyModel` that's what @kecnry suggeted just above, and a  `FluxButNotDensityReallyIMeanItBlackbodyModel` (ok, maybe a different name is needed there) which has the originally posed `scale` but not `solid_angle`.

My motivation here is that I rarely actually want to think about solid angle at all if I can avoid it, but sometimes I have to.
@eteq - I would be for that, but then `FluxButNotDensityReallyIMeanItBlackbodyModel` would likely have to raise an error if calling `bolometric_flux` or possibly could estimate through integration (over wavelength or frequency) instead.
Yeah, I'm cool with that, as long as the exception message says something like "not sure why you're seeing this?  Try using BlackbodyModel instead"
If you end up with a few new classes, the user documentation needs some serious explaining, as I feel like this is going against "There should be one-- and preferably only one --obvious way to do it" ([PEP 20](https://www.python.org/dev/peps/pep-0020/)) a little...
@eteq @pllim - it might be possible to achieve this same use-case (not having to worry about thinking about solid angle if you don't intend to make calls to `bolometric_flux`) in a single class by allowing `solid_angle = None` for the flux case and absorbing the steradians into the scale factor.  That case would then need to raise an informative error for calls to `bolometric_flux` to avoid the ambiguity issue.  The tradeoff I see is more complex argument validation logic and extended documentation in a single class rather than multiple classes for different use-cases.

If no one thinks of any major drawbacks/concerns, I will take a stab at that implementation and come up with examples for each of the use-cases discussed so far and we can then reconsider if splitting into separate classes is warranted.

Thanks for all the good ideas!
Here are some proposed pseudo-code calls that I think could cover all the cases above with a single class including new optional `solid_angle` and `output_units` arguments.  Please let me know if I've missed any cases or if any of these wouldn't act as you'd expect.  

As you can see, there are quite a few different scenarios, so this is likely to be a documentation and testing challenge - but I'm guessing any approach will have that same problem.  Ultimately though it boils down to attempting to pull the units out of `scale` to avoid the ambiguous issues brought up here, while still allowing support for output and fitting in flux units (by supporting both separating the dimensionless scale from the solid angle to allow calling `bolometric_flux` and also by absorbing them together for the case of fitting a single scale factor and sacrificing the ability to call `bolometric_flux`).


**SNU/SLAM units**

`BlackBody(temperature, [scale (float or unitless)], output_units=(None, SNU, or SLAM))`
* if `output_units` is not provided or `None`, defaults to `SNU` to match current behavior
* unitless `scale` converted to unitless_unscaled (should address this *original* bug report)
* returns in SNU/SLAM units 
* `bolometric_flux` uses unitless `scale` directly (matches current behavior)


`BlackBody(temperature, scale (SNU or SLAM units))`
* for **backwards compatibility** only
* `output_units = scale.unit`, `scale = scale.value`
* returns in SNU/SLAM units
* `bolometric_flux`: we have two options here: (1) interpret this as a unitless `scale` with units being interpreted only for the sake of output units which matches current behavior (2) raise an error that `bolometric_flux` requires unitless `scale` to be passed (see [point 3 in the comment above](https://github.com/astropy/astropy/issues/11547#issuecomment-822667522)).


`BlackBody(temperature, scale (with other units), output_units=(None, SNU, or SLAM))`
* **ERROR**: `scale` cannot have units if `output_units` are SNU or SLAM (or non-SNU/SLAM units if `output_units` not provided or None)

**FNU/FLAM units**

`BlackBody(temperature, scale (float or unitless), solid_angle (u.sr), output_units=(FNU or FLAM))`
* unitless `scale` converted to unitless_unscaled
* returns in FNU/FLAM
* `bolometric_flux` uses unitless `scale` directly (since separated from `solid_angle`)
* fitting: either raise an error if both `scale` and `solid_angle` are left unfixed or just let it be degenerate?

`BlackBody(temperature, scale (sr units), output_units=(FNU or FLAM))`
* `scale = scale.value`, `solid_angle = 1.0*u.sr` and **automatically set to be kept fixed** during fitting
* returns in FNU/FLAM
* `bolometric_flux` => ERROR: must provide separate `scale` and `solid_angle` to call `bolometric_flux` (i.e. the previous case)

`BlackBody(temperature, scale (FNU or FLAM units))`
* to match **backwards compatibility** case for SNU/SLAM
* `output_units = scale.unit`, `scale = scale.value`, `solid_angle = 1.0*u.sr` and **automatically set to be kept fixed** during fitting
* returns in FNU/FLAM units
* `bolometric_flux` => ERROR: same as above, must provide separate `scale` and `solid_angle`.

`BlackBody(temperature, scale (float, unitless, or non sr units), output_units=(FNU or FLAM))`
* **ERROR**: FNU/FLAM requires scale to have FNU/FLAM/sr units OR unitless with solid_angle provided (any of the cases above)
Upon further reflection, I think that we are twisting ourselves into a knot by treating the black body as a special case when it comes to this pesky factor of pi. It's not. The factor of pi comes up any time that you need to convert from specific intensity (S_nu a.k.a. B_nu [erg cm^-2 s^-1 Hz^-1 sr^-1]) to flux density (F_nu [erg cm^-2 s^-1 Hz^-1]) assuming that your emitting surface element radiates isotropically. It's just the integral of cos(theta) from theta=0 to pi/2.

BlackBody only looks like a special case among the astropy models because there are no other physical radiation models. If we declared a constant specific intensity source model class, then we would be having the same argument about whether we need to have a dual flux density class with an added factor of pi.

What we commonly call Planck's law is B_nu. In order to avoid confusing users who are expecting the class to use the textbook definition, the Astropy model should _not_ insert the factor of pi.

Instead, I propose that we go back to for `astropy.modeling.models.BlackBody`:

1. `scale` may have units of dimensionless_unscaled or solid angle, and in either case simply multiplies the output, or
2. has no scale parameter.

In both cases, support for scale in FNU/FLAM/SNU/SLAM is deprecated because it cannot be implemented correctly and unambiguously.

And in both cases, synphot keeps its own BlackBody1D class (perhaps renamed to BlackBodyFlux1D to mirror ConstFlux1D) and it _does_ have the factor of pi added.
BTW, I found this to be a nice refresher: https://www.cv.nrao.edu/~sransom/web/Ch2.html
> synphot keeps its own BlackBody1D class (perhaps renamed to BlackBodyFlux1D to mirror ConstFlux1D)

`synphot` never used the new blackbody stuff here, so I think it can be safely left out of the changes here. If you feel strongly about its model names, feel free to open issue at https://github.com/spacetelescope/synphot_refactor/issues but I don't think it will affect anything at `astropy` or vice versa. 😅 
@lpsinger - good points. I agree that this situation isn't fundamentally unique to BlackBody, and on further thought along those lines, can't think of any practical reason not to abstract away the `solid_angle` entirely from my use-cases above (as it should probably always either be N/A or pi - allowing it to possibly be fitted or set incorrectly just asks for problems).  I have gone back and forth with myself about your point for *not* adding support for including the pi automatically, but as long as the default behavior remains the "pure" B_nu form, I think there are significant practical advantages for supporting more flexibility.  The more this conversation continues, the more convinced I am that `scale` is indeed useful, but that we should move towards forcing it to be unitless to avoid a lot of these confusing scenarios.  I'm worried that allowing `scale` to have steradians as units will cause more confusion (although I appreciate the simplicity of just multiplying the result).

So... my (current) vote would be to still implement a separate `output_units` argument to make sure any change in units (and/or inclusion of pi) is explicitly clear and to take over the role of differentiating between specific intensity and flux density (by eventually requiring `scale` to be unitless and always handling the pi internally if requesting in flux units).

Assuming we can't remove support for units in `scale` this release without warning, that leaves us with the following:

* `BlackBody(temperature, [scale (float or unitless)], output_units=(None, SNU, or SLAM))`
* temporary support for `BlackBody(temperature, scale (SNU or SLAM units))`: this is the current supported syntax that we want to deprecate. In the meantime, we would split the `scale` quantity into `scale` (unitless) and `output_units`.  I think this still might be a bit confusing for the `bolometric_flux` case, so we may want to raise an error/warning there?
* `BlackBody(temperature, [scale (float or unitless)], output_units=(FNU or FLAM))`: since scale is unitless, it is assumed *not* to include the pi, the returned value is multiplied by `scale*pi` internally and with requested units.
* temporary support for `BlackBody(temperature, scale (FNU, FLAM))`: here `scale` includes units of solid angle, so internally we would set `scale = scale.value/pi` and then use the above treatment to multiply by `scale*pi`.  Note that this does mean the these last two cases behave a little differently for passing the same "number" to `scale`, as without units it assumes to not include the pi, but will assume to include the pi if passed as a quantity. Definitely not ideal - I suppose we don't need to add support for this case since it wasn't supported in the past.  But if we do, we may again want to raise an error/warning when calling `bolometric_flux`?

If we don't like the `output_units` argument, this could be done instead with `BlackBody` vs `BlackBodyFlux` model (similar to @eteq's suggestion earlier), still deprecate passing units to scale as described above for both classes, and leave any unit conversion between *NU and *LAM to the user.  Separate classes may be slightly cleaner looking and help separate the documentation, while a single class with the `output_units` argument provides a little more convenience functionality.
I think we should not include the factor of pi at all in the astropy model because it assumes not only that one is integrating over a solid angle, but that the temperature is uniform over the body. In general, that does not have to be the case, does it?

Would we ruffle too many feathers if we deprecated `scale` altogether?
> Would we ruffle too many feathers

Can't be worse than the episode when we deprecated `clobber` in `io.fits`... 😅 
No, not in general.  But so long as we only support a single temperature, I think it's reasonable that that would assume uniform temperature. 

I think getting rid of `scale` entirely was @karllark's original suggestion, but then all of this logic is left to be done externally (likely by the user).  My attempts to do so with the existing `Scale` or `Linear1D` models, [showed complications](https://github.com/astropy/astropy/issues/11547#issuecomment-949734738).  Perhaps I was missing something there and there's a better way... or maybe we need to work on fixing underlying bugs or lack of flexibility in `Compound` models instead.  I also agree with @eteq's [arguments that users would expect a scale](https://github.com/astropy/astropy/issues/11547#issuecomment-951154117) and that it might indeed ruffle some feathers.
> No, not in general. But so long as we only support a single temperature, I think it's reasonable that that would assume uniform temperature.

It may be fair to assume a uniform temperature, but the factor of pi is also kind of assuming that the emitting surface is a sphere, isn't it?

> I think getting rid of `scale` entirely was @karllark's original suggestion, but then all of this logic is left to be done externally (likely by the user). My attempts to do so with the existing `Scale` or `Linear1D` models, [showed complications](https://github.com/astropy/astropy/issues/11547#issuecomment-949734738). Perhaps I was missing something there and there's a better way... or maybe we need to work on fixing underlying bugs or lack of flexibility in `Compound` models instead. I also agree with @eteq's [arguments that users would expect a scale](https://github.com/astropy/astropy/issues/11547#issuecomment-951154117) and that it might indeed ruffle some feathers.

I see. In that case, it seems that we are converging toward retaining the `scale` attribute but deprecating any but dimensionless units for it. Is that an accurate statement? If so, then I can whip up a PR.
Yes, most likely a sphere, or at least anything where the solid angle is pi.  But I agree that adding the generality for any solid angle will probably never be used and just adds unnecessary complication.

I think that's the best approach for now (deprecating unit support in `scale` but supporting flux units) and then if in the future we want to completely remove `scale`, that is an option as long as external scaling can pick up the slack.  I already started on testing some implementations, so am happy to put together the PR (and will tag you so you can look at it and comment before any decision is made).
> I think that's the best approach for now (deprecating unit support in `scale` but supporting flux units) and then if in the future we want to completely remove `scale`, that is an option as long as external scaling can pick up the slack. I already started on testing some implementations, so am happy to put together the PR (and will tag you so you can look at it and comment before any decision is made).

Go for it.