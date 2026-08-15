On matplotlib master nbagg supports blitting - so I also tried with that - which prevents the high cpu usage but the smearing of the image (https://github.com/matplotlib/matplotlib/issues/19116) is renders the widget unusable:

![Peek 2021-03-03 18-35](https://user-images.githubusercontent.com/10111092/109887241-5d080780-7c4f-11eb-897a-c12af8896d31.gif)

so I think it's still important to fix the `useblit=False` case.

I think the CPU burning loop is happening because the multicursor attaches a callback to the draw_event that will it self trigger a draw event and then :infinity:  followed by :fire: :computer: :fire: 

The path is:
https://github.com/matplotlib/matplotlib/blob/6a35abfa2efdaf3b9efe49d4398164fa4cc6c3a3/lib/matplotlib/widgets.py#L1636

to https://github.com/matplotlib/matplotlib/blob/6a35abfa2efdaf3b9efe49d4398164fa4cc6c3a3/lib/matplotlib/widgets.py#L1643-L1651

and `line.set_visible` sets an artist to stale and then a draw happens again.

Confusingly this doesn't happen on the qt backend, but does on the nbagg backend???

You see this behavior with this:


```python
%matplotlib notebook
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import MultiCursor
import ipywidgets as widgets

t = np.arange(0.0, 2.0, 0.01)
s1 = np.sin(2*np.pi*t)
s2 = np.sin(4*np.pi*t)

fig, (ax1, ax2) = plt.subplots(2, sharex=True)
ax1.plot(t, s1)
ax2.plot(t, s2)

out = widgets.Output()
display(out)
n = 0
def drawn(event):
    global n
    n += 1
    with out:
        print(f'drawn! {n}')
fig.canvas.mpl_connect('draw_event', drawn)
multi = MultiCursor(fig.canvas, (ax1, ax2), color='r', lw=1, useblit=False)
plt.show()
```

![Peek 2021-03-03 19-18](https://user-images.githubusercontent.com/10111092/109890480-58dee880-7c55-11eb-9a0f-20db4066c186.gif)

Having not looked at the implementation at all, a simple fix might be to cache the mouse position (which may already be available from the existing Line2D's current position), and then not do anything if the mouse hasn't moved?
@QuLogic looking at this again I think this is about nbagg and the js side rather than anything with multicursor. A simpler reproduction is:

```python
%matplotlib nbagg
import matplotlib.pyplot as plt
from ipywidgets import Output

fig, ax = plt.subplots()
l, = ax.plot([0,1],[0,1])

out = Output()
display(out)
n =0
def drawn(event):
    global n
    n+=1
    with out:
        print(n)
    l.set_visible(False)
fig.canvas.mpl_connect('draw_event', drawn)
```

which may be due to the the draw message that the frontend sends back from here?
https://github.com/matplotlib/matplotlib/blob/33c3e72e8b228e5e1244d7792103b920df094866/lib/matplotlib/backends/web_backend/js/mpl.js#L394-L399
What is going on with `fig.stale`?

The double-buffering that nbagg does may also be contributing here.
I have been testing the matplotlib 3.4.0rc1 and I confirm the high CPU usage and significant slow down when using the notebook backend. There are also issue 
I don't have a minimum example to reproduce without installing hyperspy but what we uses is fairly similar to the [blitting tutorial](https://matplotlib.org/stable/tutorials/advanced/blitting.html). See https://github.com/hyperspy/hyperspy/blob/RELEASE_next_minor/hyperspy/drawing/figure.py for more details.

The example of the blitting tutorial doesn't seem to be working:
```python
import matplotlib.pyplot as plt
import numpy as np

x = np.linspace(0, 2 * np.pi, 100)

fig, ax = plt.subplots()

# animated=True tells matplotlib to only draw the artist when we
# explicitly request it
(ln,) = ax.plot(x, np.sin(x), animated=True)

# make sure the window is raised, but the script keeps going
plt.show(block=False)

# stop to admire our empty window axes and ensure it is rendered at
# least once.
#
# We need to fully draw the figure at its final size on the screen
# before we continue on so that :
#  a) we have the correctly sized and drawn background to grab
#  b) we have a cached renderer so that ``ax.draw_artist`` works
# so we spin the event loop to let the backend process any pending operations
plt.pause(0.1)

# get copy of entire figure (everything inside fig.bbox) sans animated artist
bg = fig.canvas.copy_from_bbox(fig.bbox)
# draw the animated artist, this uses a cached renderer
ax.draw_artist(ln)
# show the result to the screen, this pushes the updated RGBA buffer from the
# renderer to the GUI framework so you can see it
fig.canvas.blit(fig.bbox)
```
It gives an empty figure:
![image](https://user-images.githubusercontent.com/11851990/110686248-26923580-81d7-11eb-8c92-001bd0bdcf75.png)

and the following error message:
```python
---------------------------------------------------------------------------
AttributeError                            Traceback (most recent call last)
<ipython-input-2-f625949ed20b> in <module>
     26 bg = fig.canvas.copy_from_bbox(fig.bbox)
     27 # draw the animated artist, this uses a cached renderer
---> 28 ax.draw_artist(ln)
     29 # show the result to the screen, this pushes the updated RGBA buffer from the
     30 # renderer to the GUI framework so you can see it

/opt/miniconda3/lib/python3.8/site-packages/matplotlib/axes/_base.py in draw_artist(self, a)
   2936         """
   2937         if self.figure._cachedRenderer is None:
-> 2938             raise AttributeError("draw_artist can only be used after an "
   2939                                  "initial draw which caches the renderer")
   2940         a.draw(self.figure._cachedRenderer)

AttributeError: draw_artist can only be used after an initial draw which caches the renderer

```

Using blitting is now slower than without... :( Any chance to have this fix before the 3.4.0 release? Or to have if disable, through the `supports_blit` property until it is working well enough?



> What is going on with `fig.stale`?
> 
> The double-buffering that nbagg does may also be contributing here.

Changing to `print(n, 'before', l.stale, l.axes.stale, l.axes.figure.stale)` (and printing again after `l.set_visible`) prints out:
```
1 before False False False
1 after True True True
2 before True False False
2 after True True True
2 before True False False
2 after True True True
```
and never changes after that.

Whereas on `Agg` or `TkAgg`, it's all `False`, then all `True`, then stops.

So somehow the `draw_event` is called before all the Artists are marked up-to-date or something.
I think the issue here is that:

 - the `ob.clear` method is hooked up to `'draw_event'` which fires at the bottom of `Figure.draw()` (which is called from inside of Canvas.draw()`
 -  in `clear` we set the cursor artists to be not visible (and it appears to have been that way for a long time)
 - in `CanvasBase.draw_idle` and in the `pyplot._auto_draw_if_interactive` we have a whole bunch of de-bouncing logic so that the draws triggered while drawing get ignored (this is why tkagg / qtagg does not go into the same infinite loop).  I think I am missing some details here, but I do not think it changes the analysis.  In IPython we only auto-draw when the user gets the prompt back from executing something (so no loops there!).  
 - in nbagg when we trigger draw_idle on the python side we resolve that by sending a note to the front end to please request a draw.  This eventually comes back to the python side which triggers the actual render.  This extra round trip is what is opening us up to the infinite loop 
 - One critical detail I may be missing is what in triggering the `draw_idle` in the nbagg case?

This goes back to at least 3.3 so is not a recent regression.  I think that removing the `set_visible(False)` lines is the simplest and correct fix (or probably better, pulling the blit logic out into a method not called 'clear' and registering that with `draw_event` (as when we do a clean re-render (due to changing the size or similar) we need to grab a new background of the correct size).
> Whereas on `Agg` or `TkAgg`, it's all `False`, then all `True`, then stops.

But something I missed before, is that the line is actually drawn. So the stale did not trigger a re-draw in other backends. The stale handler for figures in `pyplot` is:
https://github.com/matplotlib/matplotlib/blob/bfa31a482d6baa9a6da417bc1c20d4cd93abcece/lib/matplotlib/pyplot.py#L782-L800

And the `draw_idle` for most backends will set a flag which is cleared when the draw actually happens (since they use event loops to signal this), but WebAgg does _not_. It always sends a `draw` message to the frontend, which has some sort of `waiting` flag, but I have not figured out why that does not limit things yet.
The second and subsequent `draw_idle` come from `post_execute`:
```pytb
  File ".../matplotlib/lib/matplotlib/pyplot.py", line 138, in post_execute
    draw_all()
  File ".../matplotlib/lib/matplotlib/_pylab_helpers.py", line 137, in draw_all
    manager.canvas.draw_idle()
  File ".../matplotlib/lib/matplotlib/backends/backend_webagg_core.py", line 164, in draw_idle
    traceback.print_stack(None)
```
Didn't we have a previous issue with this?
Based on the original PR https://github.com/matplotlib/matplotlib/pull/4091#issuecomment-73774842, there is `post_execute` and `post_run_cell`; why did we use the former and not the latter? Do we even need this hook at all, with the stale figure tracking?
The previous similar issue was https://github.com/matplotlib/matplotlib/issues/13971#issuecomment-609006518, and the fix in that case was to avoid causing the figure to get marked stale during draw. As @tacaswell had mentioned earlier, doing the same in `MultiCursor` is probably the best option here.