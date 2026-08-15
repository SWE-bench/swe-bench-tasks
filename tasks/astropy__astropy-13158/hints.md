Note that the simple change of https://github.com/astropy/astropy/blob/675dc03e138d5c6a1cb6936a6b2c3211f39049d3/astropy/modeling/core.py#L2704
to `value = value * unit` with the above example still passes all the modeling unit tests. However, it produces a different error
```python
---------------------------------------------------------------------------
UnitTypeError                             Traceback (most recent call last)
Input In [1], in <cell line: 8>()
      5 c = -20.0 * unit
      6 model = Const1D(c)
----> 8 model(-23.0 * unit)

File ~/projects/astropy/astropy/modeling/core.py:397, in __call__(self, model_set_axis, with_bounding_box, fill_value, equivalencies, inputs_map, *inputs, **new_inputs)
    390 args = ('self',)
    391 kwargs = dict([('model_set_axis', None),
    392                ('with_bounding_box', False),
    393                ('fill_value', np.nan),
    394                ('equivalencies', None),
    395                ('inputs_map', None)])
--> 397 new_call = make_function_with_signature(
    398     __call__, args, kwargs, varargs='inputs', varkwargs='new_inputs')
    400 # The following makes it look like __call__
    401 # was defined in the class
    402 update_wrapper(new_call, cls)

File ~/projects/astropy/astropy/modeling/core.py:376, in _ModelMeta._handle_special_methods.<locals>.__call__(self, *inputs, **kwargs)
    374 def __call__(self, *inputs, **kwargs):
    375     """Evaluate this model on the supplied inputs."""
--> 376     return super(cls, self).__call__(*inputs, **kwargs)

File ~/projects/astropy/astropy/modeling/core.py:1079, in Model.__call__(self, *args, **kwargs)
   1076 # prepare for model evaluation (overridden in CompoundModel)
   1077 evaluate, inputs, broadcasted_shapes, kwargs = self._pre_evaluate(*args, **kwargs)
-> 1079 outputs = self._generic_evaluate(evaluate, inputs,
   1080                                  fill_value, with_bbox)
   1082 # post-process evaluation results (overridden in CompoundModel)
   1083 return self._post_evaluate(inputs, outputs, broadcasted_shapes, with_bbox, **kwargs)

File ~/projects/astropy/astropy/modeling/core.py:1043, in Model._generic_evaluate(self, evaluate, _inputs, fill_value, with_bbox)
   1041     outputs = bbox.evaluate(evaluate, _inputs, fill_value)
   1042 else:
-> 1043     outputs = evaluate(_inputs)
   1044 return outputs

File ~/projects/astropy/astropy/modeling/core.py:939, in Model._pre_evaluate.<locals>.evaluate(_inputs)
    938 def evaluate(_inputs):
--> 939     return self.evaluate(*chain(_inputs, parameters))

File ~/projects/astropy/astropy/modeling/functional_models.py:1805, in Const1D.evaluate(x, amplitude)
   1802     x = amplitude * np.ones_like(x, subok=False)
   1804 if isinstance(amplitude, Quantity):
-> 1805     return Quantity(x, unit=amplitude.unit, copy=False)
   1806 return x

File ~/projects/astropy/astropy/units/quantity.py:522, in Quantity.__new__(cls, value, unit, dtype, copy, order, subok, ndmin)
    519         cls = qcls
    521 value = value.view(cls)
--> 522 value._set_unit(value_unit)
    523 if unit is value_unit:
    524     return value

File ~/projects/astropy/astropy/units/quantity.py:764, in Quantity._set_unit(self, unit)
    762         unit = Unit(str(unit), parse_strict='silent')
    763         if not isinstance(unit, (UnitBase, StructuredUnit)):
--> 764             raise UnitTypeError(
    765                 "{} instances require normal units, not {} instances."
    766                 .format(type(self).__name__, type(unit)))
    768 self._unit = unit

UnitTypeError: Quantity instances require normal units, not <class 'astropy.units.function.logarithmic.MagUnit'> instances.
```
Magnitude is such a headache. Maybe we should just stop supporting it altogether... _hides_

More seriously, maybe @mhvk has ideas.
The problem is that `Quantity(...)` by default creates a `Quantity`, which seems quite logical. But `Magnitude` is a subclass.... This is also why multiplying with the unit does work. I *think* adding `subok=True` for the `Quantity` initializations should fix the specific problems, though I fear it may well break elsewhere... 

p.s. It does make me wonder if one shouldn't just return a subclass in the first place if the unit asks for that.
> The problem is that `Quantity(...)` by default creates a `Quantity`, which seems quite logical. But `Magnitude` is a subclass.... This is also why multiplying with the unit does work. I _think_ adding `subok=True` for the `Quantity` initializations should fix the specific problems, though I fear it may well break elsewhere...

For my reproducer adding `subok=True` everywhere in the call stack that uses `Quantity(...)` does prevent mitigate the bug. I guess a possible fix for this bug is to ensure that `Quantity` calls in modeling include this optional argument.

> p.s. It does make me wonder if one shouldn't just return a subclass in the first place if the unit asks for that.

This change could make things a bit easier for modeling. I'm not sure why this is not the default.