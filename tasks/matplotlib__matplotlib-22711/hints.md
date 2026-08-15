Huh, the polygon object must have changed inadvertently. Usually, you have
to "close" the polygon by repeating the first vertex, but we make it
possible for polygons to auto-close themselves. I wonder how (when?) this
broke?

On Tue, Mar 22, 2022 at 10:29 PM vpicouet ***@***.***> wrote:

> Bug summary
>
> I think xy[4] = .25, val[0] should be commented in /matplotlib/widgets.
> py", line 915, in set_val
> as it prevents to initialized value for RangeSlider
> Code for reproduction
>
> import numpy as npimport matplotlib.pyplot as pltfrom matplotlib.widgets import RangeSlider
> # generate a fake imagenp.random.seed(19680801)N = 128img = np.random.randn(N, N)
> fig, axs = plt.subplots(1, 2, figsize=(10, 5))fig.subplots_adjust(bottom=0.25)
> im = axs[0].imshow(img)axs[1].hist(img.flatten(), bins='auto')axs[1].set_title('Histogram of pixel intensities')
> # Create the RangeSliderslider_ax = fig.add_axes([0.20, 0.1, 0.60, 0.03])slider = RangeSlider(slider_ax, "Threshold", img.min(), img.max(),valinit=[0.0,0.0])
> # Create the Vertical lines on the histogramlower_limit_line = axs[1].axvline(slider.val[0], color='k')upper_limit_line = axs[1].axvline(slider.val[1], color='k')
>
> def update(val):
>     # The val passed to a callback by the RangeSlider will
>     # be a tuple of (min, max)
>
>     # Update the image's colormap
>     im.norm.vmin = val[0]
>     im.norm.vmax = val[1]
>
>     # Update the position of the vertical lines
>     lower_limit_line.set_xdata([val[0], val[0]])
>     upper_limit_line.set_xdata([val[1], val[1]])
>
>     # Redraw the figure to ensure it updates
>     fig.canvas.draw_idle()
>
> slider.on_changed(update)plt.show()
>
> Actual outcome
>
>   File "<ipython-input-52-b704c53e18d4>", line 19, in <module>
>     slider = RangeSlider(slider_ax, "Threshold", img.min(), img.max(),valinit=[0.0,0.0])
>
>   File "/Users/Vincent/opt/anaconda3/envs/py38/lib/python3.8/site-packages/matplotlib/widgets.py", line 778, in __init__
>     self.set_val(valinit)
>
>   File "/Users/Vincent/opt/anaconda3/envs/py38/lib/python3.8/site-packages/matplotlib/widgets.py", line 915, in set_val
>     xy[4] = val[0], .25
>
> IndexError: index 4 is out of bounds for axis 0 with size 4
>
> Expected outcome
>
> range slider with user initial values
> Additional information
>
> error can be
>
>
>     def set_val(self, val):
>         """
>         Set slider value to *val*.
>
>         Parameters
>         ----------
>         val : tuple or array-like of float
>         """
>         val = np.sort(np.asanyarray(val))
>         if val.shape != (2,):
>             raise ValueError(
>                 f"val must have shape (2,) but has shape {val.shape}"
>             )
>         val[0] = self._min_in_bounds(val[0])
>         val[1] = self._max_in_bounds(val[1])
>         xy = self.poly.xy
>         if self.orientation == "vertical":
>             xy[0] = .25, val[0]
>             xy[1] = .25, val[1]
>             xy[2] = .75, val[1]
>             xy[3] = .75, val[0]
>             # xy[4] = .25, val[0]
>         else:
>             xy[0] = val[0], .25
>             xy[1] = val[0], .75
>             xy[2] = val[1], .75
>             xy[3] = val[1], .25
>             # xy[4] = val[0], .25
>         self.poly.xy = xy
>         self.valtext.set_text(self._format(val))
>         if self.drawon:
>             self.ax.figure.canvas.draw_idle()
>         self.val = val
>         if self.eventson:
>             self._observers.process("changed", val)
>
>
> Operating system
>
> OSX
> Matplotlib Version
>
> 3.5.1
> Matplotlib Backend
>
> *No response*
> Python version
>
> 3.8
> Jupyter version
>
> *No response*
> Installation
>
> pip
>
> —
> Reply to this email directly, view it on GitHub
> <https://github.com/matplotlib/matplotlib/issues/22686>, or unsubscribe
> <https://github.com/notifications/unsubscribe-auth/AACHF6CW2HVLKT5Q56BVZDLVBJ6X7ANCNFSM5RMUEIDQ>
> .
> You are receiving this because you are subscribed to this thread.Message
> ID: ***@***.***>
>

Yes, i might have been too fast, cause it allows to skip the error but then it seems that the polygon is not right...
Let me know if you know how this should be solved...
![Capture d’écran, le 2022-03-22 à 23 20 23](https://user-images.githubusercontent.com/37241971/159617326-44c69bfc-bf0a-4f79-ab23-925c7066f2c2.jpg)


So I think you found an edge case because your valinit has both values equal. This means that the poly object created by `axhspan` is not as large as the rest of the code expects. 

https://github.com/matplotlib/matplotlib/blob/11737d0694109f71d2603ba67d764aa2fb302761/lib/matplotlib/widgets.py#L722

A quick workaround is to have the valinit contain two different numbers (even if only minuscule difference)
Yes you are right!
Thanks a lot for digging into this!!
Compare:

```python
import matplotlib.pyplot as plt
fig, ax = plt.subplots()
poly_same_valinit = ax.axvspan(0, 0, 0, 1)
poly_diff_valinit = ax.axvspan(0, .5, 0, 1)
print(poly_same_valinit.xy.shape)
print(poly_diff_valinit.xy.shape)
```

which gives:

```
(4, 2)
(5, 2)
```

Two solutions spring to mind:

1. Easier option
Throw an error in init if `valinit[0] == valinit[1]`

2. Maybe better option?
Don't use axhspan and manually create the poly to ensure it always has the expected number of vertices
Option 2 might be better yes
@vpicouet any interest in opening a PR?
I don't think I am qualified to do so, never opened a PR yet. 
RangeSlider might also contain another issue. 
When I call `RangeSlider.set_val([0.0,0.1])`
It changes only the blue poly object and the range value on the right side of the slider not the dot:
![Capture d’écran, le 2022-03-25 à 15 53 44](https://user-images.githubusercontent.com/37241971/160191943-aef5fbe2-2f54-42ae-9719-23375767b212.jpg)
 
> I don't think I am qualified to do so, never opened a PR yet.

That's always true until you've opened your first one :). But I also understand that it can be intimidating.


>  RangeSlider might also contain another issue.
> When I call RangeSlider.set_val([0.0,0.1])
> It changes only the blue poly object and the range value on the right side of the slider not the dot:


oh hmm - good catch! may be worth opening a separate issue there as these are two distinct bugs and this one may be a bit more comlicated to fix.
Haha true! I might try when I have more time!
Throwing an error at least as I have never worked with axhspan and polys.
Ok, openning another issue.
Can I try working on this? @ianhi @vpicouet 
From the discussion, I could identify that a quick fix would be to use a try-except block to throw an error 
if valinit[0] == valinit[1]

Please let me know your thoughts.
Sure! 