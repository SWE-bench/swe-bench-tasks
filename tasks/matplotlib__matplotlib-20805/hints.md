Its hard to tell from the above what the bug is.  If I simplify, and do:

```python
import matplotlib.pyplot as plt
import matplotlib.ticker
import numpy as np

X = np.arange(100)
Y = X**2+3

fig1, (ax1, ax2) = plt.subplots(1, 2, constrained_layout=True)

ax1.plot(X,Y)
ax1.set_xlabel("X",fontsize='small')
ax1.set_ylabel("Y")
ax1.tick_params(axis='x', colors="green", grid_color='g',labelsize='small', labelrotation = 45)
ax1.set_ylim(max(Y), min(Y))

ax2.plot(X,Y)
ax2.set_xlabel("X",fontsize='small')
ax2.set_ylabel("Y")
ax2.tick_params(axis='x', colors="green", grid_color='g',labelsize='small', labelrotation = 45)
ax2.set_ylim(max(Y), min(Y))
ax2.yaxis.set_label_position("right")
ax2.yaxis.tick_right()

for ax in [ax1, ax2]:
    ax.xaxis.set_ticks_position("top")
    ax.xaxis.set_label_position("top")
    ax.grid(b = True, which='both', axis = 'both', color='gainsboro',
            linestyle='-')

plt.show()
```

I get the following.  Was this not what was desired?  Maybe include a png of what you get?

![Spines](https://user-images.githubusercontent.com/1562854/128201606-1b6c38d8-bc36-4d7c-ae04-7161e52043e0.png)

Hello Jody, thanks for getting back to me.  The question is specific to the use of the spines command wit the tick_params.

You basically get 2 results depending if you write:
ax1.spines["top"].set_position(("axes", 1.05))
ax1.tick_params(axis='x', colors="green", grid_color='g',labelsize='small', labelrotation = 45)

vs

ax1.tick_params(axis='x', colors="green", grid_color='g',labelsize='small', labelrotation = 45)
ax1.spines["top"].set_position(("axes", 1.05))

The second scenario partially reads the tick_params command, namely the labelrotation.  That's the real question for this post.

OK, so the _minimal_ example is. I'm not sure what causes this hysteresis.  

```python
import matplotlib.pyplot as plt

fig1, (ax1, ax2) = plt.subplots(1, 2)

ax1.spines["top"].set_position(("axes", 1.05))
ax1.tick_params(axis='x', labelrotation=45)

ax2.tick_params(axis='x', labelrotation=45)
ax2.spines["top"].set_position(("axes", 1.05))

for ax in [ax1, ax2]:
    ax.xaxis.set_ticks_position("top")
    ax.xaxis.set_label_position("top")

plt.show()
```

![Spines](https://user-images.githubusercontent.com/1562854/128211364-a4ade246-e810-4640-8344-e0a1736cffd6.png)

That's correct Judy.  Thanks for boiling it down to the minimum and yes no idea what causes this behavior.
Did it ever work to your knowledge?
It took me a whole day to figure out what was going on until I boiled it down to that issue so no, I have no idea if it ever worked.  It seems that there is some sort of precedence/order that one has to follow with those two commands.
And like I said, it seems that it's only a partial issue.  So far I have noticed this only with the "labelrotation" but when it comes to color, fonts, etc I haven't seen this issue.
`Spine.set_position` calls `self.axis.reset_ticks`, which would otherwise make them stuck in the old position, but also resets the rotation. It shouldn't do that though; I'm not sure why it gets lost.
> ```python
> for ax in [ax1, ax2]:
>     ax.xaxis.set_ticks_position("top")
>     ax.xaxis.set_label_position("top")
> ```

This part appears unnecessary for reproduction.
>  I'm not sure why it gets lost.

Ah, actually, it isn't lost; rather, re-creating the ticks through `XTick`/`YTick` does not apply everything from `Axis.set_tick_params`, as their constructors do not accept/apply all the values it can do.