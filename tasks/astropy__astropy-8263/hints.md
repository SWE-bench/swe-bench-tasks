Thanks for the details. That commit was part of #7649 . cc @mhvk 
Here's a more detailed traceback done from 3a478ca2:

```python
plasmapy/physics/tests/test_distribution.py:21 (test_astropy)
def test_astropy():
        v=1*u.m/u.s
>       Maxwellian_1D(v=v, T=30000 * u.K, particle='e', v_drift=0 * u.m / u.s)

plasmapy/physics/tests/test_distribution.py:24: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
plasmapy/physics/distribution.py:142: in Maxwellian_1D
    return distFunc.to(u.s / u.m)
../../astropy/astropy/units/quantity.py:669: in to
    return self._new_view(self._to_value(unit, equivalencies), unit)
../../astropy/astropy/units/quantity.py:641: in _to_value
    equivalencies=equivalencies)
../../astropy/astropy/units/core.py:984: in to
    return self._get_converter(other, equivalencies=equivalencies)(value)
../../astropy/astropy/units/core.py:915: in _get_converter
    raise exc
../../astropy/astropy/units/core.py:901: in _get_converter
    self, other, self._normalize_equivalencies(equivalencies))
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = Unit("s / m"), unit = Unit("s / m"), other = Unit("s / m")
equivalencies = []

    def _apply_equivalencies(self, unit, other, equivalencies):
        """
        Internal function (used from `_get_converter`) to apply
        equivalence pairs.
        """
        def make_converter(scale1, func, scale2):
            def convert(v):
                return func(_condition_arg(v) / scale1) * scale2
            return convert
    
        for funit, tunit, a, b in equivalencies:
            if tunit is None:
                try:
                    ratio_in_funit = (other.decompose() /
                                      unit.decompose()).decompose([funit])
                    return make_converter(ratio_in_funit.scale, a, 1.)
                except UnitsError:
                    pass
            else:
                try:
                    scale1 = funit._to(unit)
                    scale2 = tunit._to(other)
                    return make_converter(scale1, a, scale2)
                except UnitsError:
                    pass
                try:
                    scale1 = tunit._to(unit)
                    scale2 = funit._to(other)
                    return make_converter(scale1, b, scale2)
                except UnitsError:
                    pass
    
        def get_err_str(unit):
            unit_str = unit.to_string('unscaled')
            physical_type = unit.physical_type
            if physical_type != 'unknown':
                unit_str = "'{0}' ({1})".format(
                    unit_str, physical_type)
            else:
                unit_str = "'{0}'".format(unit_str)
            return unit_str
    
        unit_str = get_err_str(unit)
        other_str = get_err_str(other)
    
        raise UnitConversionError(
            "{0} and {1} are not convertible".format(
>               unit_str, other_str))
E       astropy.units.core.UnitConversionError: 's / m' and 's / m' are not convertible

../../astropy/astropy/units/core.py:885: UnitConversionError
```
I think I've got something. At the end of the problematic `Maxwellian_1D` function, we have a `return distFunc.to(u.s / u.m)`. In what follows, `unit` is the unit of `distFunc` and `other` is `u.s / u.m`:

```python
(plasmapy-tests) 18:07:23 dominik: ~/Code/PlasmaPy/PlasmaPy $ pytest --doctest-modules --pdb plasmapy/physics/distribution.py  
=========================================================================== test session starts ============================================================================
platform linux -- Python 3.7.0, pytest-4.0.1, py-1.7.0, pluggy-0.8.0
rootdir: /home/dominik/Code/PlasmaPy/PlasmaPy, inifile: setup.cfg
plugins: remotedata-0.3.1, openfiles-0.3.1, doctestplus-0.2.0, arraydiff-0.2
collected 8 items                                                                                                                                                          

plasmapy/physics/distribution.py F
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> traceback >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
098         \equiv \frac{1}{\sqrt{\pi v_{Th}^2}} e^{-(v - v_{drift})^2 / v_{Th}^2}
099 
100     where :math:`v_{Th} = \sqrt{2 k_B T / m}` is the thermal speed
101 
102     Examples
103     --------
104     >>> from plasmapy.physics import Maxwellian_1D
105     >>> from astropy import units as u
106     >>> v=1*u.m/u.s
107     >>> Maxwellian_1D(v=v, T=30000 * u.K, particle='e', v_drift=0 * u.m / u.s)
UNEXPECTED EXCEPTION: UnitConversionError("'s / m' and 's / m' are not convertible")
Traceback (most recent call last):

  File "/home/dominik/.miniconda3/envs/plasmapy-tests/lib/python3.7/doctest.py", line 1329, in __run
    compileflags, 1), test.globs)

  File "<doctest plasmapy.physics.distribution.Maxwellian_1D[3]>", line 1, in <module>

  File "/home/dominik/Code/PlasmaPy/PlasmaPy/plasmapy/physics/distribution.py", line 142, in Maxwellian_1D
    return distFunc.to(u.s / u.m)

  File "/home/dominik/Code/astropy/astropy/units/quantity.py", line 669, in to
    return self._new_view(self._to_value(unit, equivalencies), unit)

  File "/home/dominik/Code/astropy/astropy/units/quantity.py", line 641, in _to_value
    equivalencies=equivalencies)

  File "/home/dominik/Code/astropy/astropy/units/core.py", line 984, in to
    return self._get_converter(other, equivalencies=equivalencies)(value)

  File "/home/dominik/Code/astropy/astropy/units/core.py", line 915, in _get_converter
    raise exc

  File "/home/dominik/Code/astropy/astropy/units/core.py", line 901, in _get_converter
    self, other, self._normalize_equivalencies(equivalencies))

  File "/home/dominik/Code/astropy/astropy/units/core.py", line 885, in _apply_equivalencies
    unit_str, other_str))

astropy.units.core.UnitConversionError: 's / m' and 's / m' are not convertible

/home/dominik/Code/PlasmaPy/PlasmaPy/plasmapy/physics/distribution.py:107: UnexpectedException
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> entering PDB >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
> /home/dominik/Code/astropy/astropy/units/core.py(885)_apply_equivalencies()
-> unit_str, other_str))
(Pdb) p vars(unit)
{'_bases': [Unit("m"), Unit("s")], '_powers': [-1.0, 1.0], '_scale': 1.0, '_decomposed_cache': Unit("s / m")}
(Pdb) p vars(other)
{'_scale': 1.0, '_bases': [Unit("s"), Unit("m")], '_powers': [1, -1], '_decomposed_cache': Unit("s / m")}
```

So I think this has something to do with that the fact that `_powers` are **floats** in one case and `int`s in another. It may also have to do with the fact that `_bases` don't have the same ordering and thus you can't simply (as I assume this does somewhere... haven't been able to track it down) cast powers to a common numeric type and check if they agree. They have to be sorted with the same ordering that sorts `_bases` first.
Damn, and here I just moved the `units` module indicator to `stable`! I'll try to trace down further (the hints certainly are helpful!)
OK, here is an astropy-only version (proving it is purely an astropy bug):
```
import astropy.units as u
v2 = 1*u.m**2/u.s**2
(v2 ** (-1/2)).to(u.s/u.m)
# UnitConversionError: 's / m' and 's / m' are not convertible
```

The real problem is that the *order* of the powers is flipped, which means the bases are not sorted.