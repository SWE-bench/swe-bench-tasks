This is because the min/max is clipped to the opposite min/max in case only one is being set. But if setting both min/max together, it doesn't make sense to do that clipping.
It seems like changing the parameter valinit also has an effect on the value set by set_val. The example below will set the value of the range slider to (1, 6). Without the valinit parameter, it would result in the value (1, 3.25).
```python
slider= widgets.RangeSlider(ax4, "wrong", valinit=(6, 10), valmin=1.0, valmax=10.0)
slider.set_val((1, 2))
print(slider.val)
```
Using (valmin, valmax) as the valinit parameter will result in correct behaviour when using set_val.
Yes, the clipping is incorrectly to the existing values.