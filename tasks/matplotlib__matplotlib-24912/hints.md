I agree that at the very least this should be an option.  I think the original 3.0 "feature" to provide a contour that wasn't asked for is of pretty dubious value   
What ever we do to `contour` we need to do the same thing for `contourf`.

Looking at the code around https://github.com/matplotlib/matplotlib/blob/7c6a74c47accdfb8d66e526cbd0b63c29ffede12/lib/matplotlib/contour.py#L1161-L1167 my suspicion is that we did not add this feature for 3.0, but preserved the behavior from previous versions. 

Looking at the blame, this originally came in via https://github.com/matplotlib/matplotlib/pull/8719 (mpl2.1) to fix https://github.com/matplotlib/matplotlib/issues/7486 which crashed rather than continuing on if there was no data in the levels.

It is probably worth revisiting given subsequent work on the Python side management around contouring and pulling contourpy out.

I'm nominally in favor of changing this warning to say "and we will plot to contours in the future" and changing the default behavior, but we can not trade the current behavior for bringing back a crash ;)

The user-side work around is to in your batch processing check the limits and do not call contour if nothing is in range.

attn @ianthomas23 
> 

I can confirm that the "unwanted" contours were not present in 2.X (2.0.2, at least). My code has been running on python 2.7 (matplotlib 2.0.2) for years without any unwanted contours, but they appeared today when testing my code with python 3.10 (matplotlib 3.5.3).

After struggling a bit, my attempted workaround was something close to what you said:

```
DO_CONTOURS = False
data_min = np.nanmin(data)
data_max = np.nanmax(data)

for level in levels:
    if level > data_min and level < data_max:
        DO_CONTOURS = True
        break

if DO_CONTOURS:
    plt.contour(...)
```

However, this workaround fails when the axes are only displaying a subset of the full array. For example, my `levels` may fall within the range of `data`, but I may be plotting a region where no contour will be needed. In that case, matplotlib once again overrides `levels` and I end up with a mess of unwanted contours.
That does track as we added it is 2.1.

I do not think we are doing any clipping in x/y internally and are always considering the full data passed in so I assume you are doing the sub-selection?  I would do something like

```python
def contour_safe(data, levels):
    return np.any(data.max() > levels) & np.any(data.min() < levels)

if contour_safe(trimmed_data, levels):
    ax.contour(..., trimmed_data, levels, ...)
```

rather than trying to cache it.

If you have this through out your code base, it might be worth writing a helper like

```python
def fixed_contour(...):
    if contour_safe(...):
        return plt.contour(...)
```
(but that does require absorbing the type instability).  Hopefully you can find-and-replace to victory of plt.contour -> fixed_contour.  This approach should also be back and forward compatible.

------

Did you have any other big surprises jumping from 2.0 -> 3.5 (effectively 6 feature releases!)?


-----

https://www.youtube.com/watch?v=LTMguK-XJEo might be of interest as well....

I'll take a look. I can't offhand think of any reason why the contouring itself needs it to be this way, and I have a vague recollection that it is the interaction with the colorbar which makes it more complicated. But that is a recollection from `n` years ago where `n > 4`!
Looking into this, I think we are absolutely fine to remove the overriding of `self.levels = [self.zmin]`. `contour` handles this without any problem. It seems that both `matplotlib` and `contourpy` are more robust to strange inputs than they used to be.

We should probably add a check for no levels specified by the user for a `contour` call, as already happens for `contourf`.

There are problems with the use of `colorbar` with this fix, but the error is `IndexError: index 0 is out of bounds for axis 0 with size 0` which is exactly the same as in issue #23817 and occurs regardless of overriding `self.levels`. I conclude that we need to make `colorbar` more robust to corner cases.