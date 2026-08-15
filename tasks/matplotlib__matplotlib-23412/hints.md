Upon digging deeper into this issue it appears that this actually the intended behavior: https://github.com/matplotlib/matplotlib/blob/f8cd2c9f532f65f8b2e3dec6d54e03c48721233c/lib/matplotlib/patches.py#L588 

So it might be prudent to just update the docstring to reflect this fact.

I'm curious why this was made the default behavior though
replacing the 0 here with the passed offset works completely fine on my OSX and Ubuntu setups.
https://github.com/matplotlib/matplotlib/blob/f8cd2c9f532f65f8b2e3dec6d54e03c48721233c/lib/matplotlib/patches.py#L590
@oliverpriebe Why do you want to do this?   

On one hand, we will sort out how to manage changing behavior when we need to, but on the other hand we need to have a very good reason to change long-standing behavior!
I'd like to use edge colors (red/blue) to denote a binary property of an entity represented by a rectangular patch that may overlap exactly with another entity with the opposite property value. When they overlap I'd like to easily see the two colors -- which isn't possible by just using low alphas. 

Admittedly this is both a niche use case and can be worked around by hacking the onoffseq as so 

```
plt.figure(1); plt.clf()
ax = plt.gca()
ax.add_patch(mpl.patches.Rectangle(
                  (0, 0),
                  1, 1,
                  facecolor = 'gray',
                  edgecolor = 'r',
                  linestyle = (0, [6, 0, 0, 6]),
                  fill = True
                ))
ax.add_patch(mpl.patches.Rectangle(
                  (0, 0),
                  1, 1,
                  facecolor = 'gray',
                  edgecolor = 'r',
                  linestyle = (0, [0, 6, 6, 0]),
                  fill = True
                ))
ax.set_xlim([-2, 2])
ax.set_ylim([-2, 2])
```
but it might save the next poor soul some time if the docstring was updated
I couldn't find a reason why we should ignore dash offset here. If this was intended, we should issue a warning if the user sets a non-zero value. However I rather think this was an oversight and even though noticed, nobody bothered to take action.

https://github.com/matplotlib/matplotlib/blob/d1f6b763d0b122ad4787bbc43cc8dbd1652bf4b5/lib/matplotlib/patches.py#L588

This is a niche feature that almost nobody will use. But AFAICS, there's little harm in supporting offests here. The only user code we could break with that is if users would explicitly have set an offset but rely on it not being applied. That's not something we'd have to guard against. To me this is simply a bug (affecting very little users), and we could fix it right away.
Marking this as good first issue as there is a minor modification required. Most work will be related to tests, probably an equality test with the workaround and the fixed code, and writing a sensible user release note clarifying that this has been fixed.