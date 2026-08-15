`horizontalalignment` is relative to the x, y of the title, which in this case is the center of the legend box.  

I agree that it would make sense for `legend.set_title` to accept a `loc` kwarg, just like the axes title does.  Looks like a `self._legend_box.align=loc` in `set_title` would do the trick.  Did you want to try a PR?  (Yes I know `loc` is a bit goofy, but its what `title` does now, so for consistency...)
Actually, `legend()` has already a `loc` kwarg, which defines the position of the legend. We would need `title_loc` or preferably `title_align`.

Also, `self._legend_box` is a `VPacker`. Setting `align` there affects the title and box containing the handles. This is not necessarily equivalent to aligning the title. For example, if the title is wider than the handles the alignment is effectively visible on the handles. So the mechanism has to be more refined than just setting `self._legend_box.align`.
Oops.   Maybe remove good first issue.  I thought it strange that modifying the legend box got the desired effect. 
This would actually need more substantial changes in the layouting of the legend. Not sure we have enough layout control mechanisms in place to do this.
Instead of building up a rather complex API here I would be very much in favour of making the vpackers and hpackers in legend public, such that users may easily manipulate them the way they like. They do that anyways, (in this case probably due to [my bad influence](https://stackoverflow.com/a/44620643/4124317)) but then with a clear concience :wink:.
@ImportanceOfBeingErnest, Absolutely it was your bad influence! Haha!

Just wondering: Couldn't the "x" of the title be moved to the same x as the handles, or a fixed distance from the left edge of the legend?

@Marriaga Unfortunately its not that easy.  The two objects in the VPacker don't really know anything about each other's widths the way its written now, so they can either be centre aligned or left/right aligned.  Both have issues though depending on the relative size of the legend title and the legend entries.  

I'm -0.5 on making the packers public.  That API is pretty mysterious, and you might as well just tell people to use private methods if you tell people to directly manipulate these objects.  Making them public makes it impossible for us to change this code in the future.  

I guess I'm actually not really sure that just changing the align of `_legend_box` is a problem.  My guess is that someone who wants the title left aligned would be OK w/ the whole legend being left-aligned, in which case thsi goes back to being a one-line fix in legend (plus documentation and tests!)

![legends](https://user-images.githubusercontent.com/1562854/46436664-42dc3f00-c70e-11e8-9634-743a5eef1511.png)

```python
import numpy as np
import matplotlib.pyplot as plt

fig, axs = plt.subplots(1, 2, figsize=(5,3))

for i in range(2):
    ax = axs[i]
    ax.plot(range(10), label='Boo')
    ax.plot(range(10), label='Who')
    leg = ax.legend(loc='center left')
    if i==1:
        leg.set_title('Long Legend Title')
    else:
        leg.set_title('Short')

    leg._legend_box.align='left'

plt.show()
```




I'm also -0.5 on making the Packers public. The API seems not mature enough to be released. A possible workaround to support title positioning could be to support a list of values for VPacker(align=...).

So that we could add `legend(title_align=...)` and do
~~~
        self._legend_box = VPacker(...,
                                   align=[title_align, "center"],
                                   children=[self._legend_title_box,
                                             self._legend_handle_box])
~~~

#### Side remark:
Actually, the current choice for `align=center` (top row) is not optimal.

![grafik](https://user-images.githubusercontent.com/2836374/46443688-ebba8680-c76e-11e8-9047-b4520e191942.png)

While it looks good with short titles (top left), long titles result in awkwardly centered entires (top right). OTOH, with `align=left` both versions would look ok (bottom).

***Would we be willing to change that to `align=left`?***
(maybe with the above extension to separately align the title i.e. `align=[title_align, "left"]`)

~~~
import matplotlib.pyplot as plt

fig, axs = plt.subplots(2, 2)
axs[0, 0].plot([0, 3, 2], label='long label spam')
axs[0, 0].plot([2, 3], label='b')
axs[0, 0].legend(title='title', loc=4)
axs[0, 1].plot([0, 3, 2], label='a')
axs[0, 1].plot([2, 3], label='b')
axs[0, 1].legend(title='long title centered', loc=4)
axs[1, 0].plot([0, 3, 2], label='long label smap')
axs[1, 0].plot([2, 3], label='b')
axs[1, 0].legend(title='title', loc=4)._legend_box.align='left'
axs[1, 1].plot([0, 3, 2], label='a')
axs[1, 1].plot([2, 3], label='b')
axs[1, 1].legend(title='long title left spam', loc=4)._legend_box.align='left'
~~~
a) I think it'd be fine to add a kwarg, but maybe just add it to `legend.set_title` to keep legend's already prodigious kwarg list under control?  People who want to fiddle w/ the position can do the extra legwork...
b) *I'd* be willing to change the default to `align='left'` but I have no idea how much that would change other people's code.  It wouldn't *break* anything though, so probably alright?  
Because someone [just asked on gitter](https://gitter.im/matplotlib/matplotlib?at=5bb7e7461e23486b9394a585) about the legend text alignment, I'm mentionning it here, as it seems related and equally not easily adjustable. A workaround could be


```
import matplotlib.pyplot as plt

fig, ax = plt.subplots()
ax.plot([1,2,3], label="AB")
ax.plot([3,2,4], label="CDEFGHI")
leg = ax.legend(title='Title', loc=4)

hp = leg._legend_box.get_children()[1]
for vp in hp.get_children():
    for row in vp.get_children():
        row.set_width(100)  # need to adapt this manually
        row.mode= "expand"
        row.align="right"

plt.show()
```

![image](https://user-images.githubusercontent.com/23121882/46566498-d6388e80-c91f-11e8-8b2b-d94144099461.png)

So this could be taken into account for whatever action is taken here for the title.
Whatever you implement, you should also consider what it looks like if someone passes 'right'.

Here's what happens when varying _legend_box.align:

![printscreen](https://user-images.githubusercontent.com/28363225/49251296-02c7ce80-f3d6-11e8-865a-1e7b3eb37c8b.png)

```
import matplotlib.pyplot as plt

fig, axs = plt.subplots(3, 2)
axs[0, 0].plot([0, 3, 2], label='long label spam')
axs[0, 0].plot([2, 3], label='b')
axs[0, 0].legend(title='title', loc=4)
axs[0, 1].plot([0, 3, 2], label='a')
axs[0, 1].plot([2, 3], label='b')
axs[0, 1].legend(title='long title centered', loc=4)
axs[1, 0].plot([0, 3, 2], label='long label smap')
axs[1, 0].plot([2, 3], label='b')
axs[1, 0].legend(title='title', loc=4)._legend_box.align='left'
axs[1, 1].plot([0, 3, 2], label='a')
axs[1, 1].plot([2, 3], label='b')
axs[1, 1].legend(title='long title left spam', loc=4)._legend_box.align='left'
axs[2, 0].plot([0, 3, 2], label='long label smap')
axs[2, 0].plot([2, 3], label='b')
axs[2, 0].legend(title='title', loc=4)._legend_box.align='right'
axs[2, 1].plot([0, 3, 2], label='a')
axs[2, 1].plot([2, 3], label='b')
axs[2, 1].legend(title='long title right spam', loc=4)._legend_box.align='right'
```

If somebody really wants to get into this, it might be sweet if one was able to align the whole legend right, with the labels on the right. That sometimes looks better when the legend is at the right of a plot.
Hi, would be great to have this feature, I just stumbled over this issue here, but the title alignment has bothered me for years now. I can put a PR together to move this forward, if no one else is working on it.
@HDembinski that'd be great!