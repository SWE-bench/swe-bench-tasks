Looks like this basically comes from trying to re-draw() a figure hosting an non-repeating animation, after the animation has finished running (tbh it's not clear to me what the semantics should be).  In the OP's example this comes from savefig() returning to the event loop, but this can be triggered with a single figure with
```python
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

fig, ax = plt.subplots()
plt.plot([1,2,3],[2,4,3])
def update(frame):
	return []
animation = FuncAnimation(fig, update, frames=iter(range(10)), repeat=False, blit=True, interval=100)
animation.save("hi.mp4")

fig.canvas.draw()
```
and appears to throw at least as far back as 3.0.
Hi @anntzer, thank you for your answer! In my application the animation and the figure to save are completely unrelated, they even live in different files, nevertheless I am experiencing this issue. If you have any tips on how to overcome this, please let know :).
ok, I understand @anntzer 's minimal reproduction case (the animation installis a single-shot callback to run after the first `draw` to start the "live" animation, we exhaust the data source before it gets drawn so the callback fails.

On `tkagg` I get a much deeper callback which shows this:

```

In [1]: import matplotlib.pyplot as plt 
   ...: from matplotlib.animation import FuncAnimation 
   ...:  
   ...: fig, ax = plt.subplots() 
   ...: plt.plot([1,2,3],[2,4,3]) 
   ...: def update(frame): 
   ...: ^Ireturn [] 
   ...: animation = FuncAnimation(fig, update, frames=iter(range(10)), repeat=False, blit=True, interval=100) 
   ...: animation.save("hi.mp4") 
   ...:  
   ...: fig.canvas.draw()                                                                                                                                            
---------------------------------------------------------------------------
StopIteration                             Traceback (most recent call last)
<ipython-input-1-8ae542acb6bd> in <module>
      8 animation = FuncAnimation(fig, update, frames=iter(range(10)), repeat=False, blit=True, interval=100)
      9 animation.save("hi.mp4")
---> 11 fig.canvas.draw()

~/.virtualenvs/bleeding/lib/python3.10/site-packages/matplotlib/backends/backend_tkagg.py in FigureCanvasTkAgg.draw(self)
      8 def draw(self):
----> 9     super(FigureCanvasTkAgg, self).draw()
     10     _backend_tk.blit(self._tkphoto, self.renderer._renderer, (0, 1, 2, 3))
     11     self._master.update_idletasks()

~/.virtualenvs/bleeding/lib/python3.10/site-packages/matplotlib/backends/backend_agg.py in FigureCanvasAgg.draw(self)
    403 # Acquire a lock on the shared font cache.
    404 with RendererAgg.lock, \
    405      (self.toolbar._wait_cursor_for_draw_cm() if self.toolbar
    406       else nullcontext()):
--> 407     self.figure.draw(self.renderer)
    408     # A GUI class may be need to update a window using this draw, so
    409     # don't forget to call the superclass.
    410     super().draw()

~/.virtualenvs/bleeding/lib/python3.10/site-packages/matplotlib/artist.py in allow_rasterization.<locals>.draw_wrapper(artist, renderer, *args, **kwargs)
     38     if artist.get_agg_filter() is not None:
     39         renderer.start_filter()
---> 41     return draw(artist, renderer, *args, **kwargs)
     42 finally:
     43     if artist.get_agg_filter() is not None:

~/.virtualenvs/bleeding/lib/python3.10/site-packages/matplotlib/figure.py in Figure.draw(self, renderer)
   1865 finally:
   1866     self.stale = False
-> 1868 self.canvas.draw_event(renderer)

~/.virtualenvs/bleeding/lib/python3.10/site-packages/matplotlib/backend_bases.py in FigureCanvasBase.draw_event(self, renderer)
   1757 s = 'draw_event'
   1758 event = DrawEvent(s, self, renderer)
-> 1759 self.callbacks.process(s, event)

~/.virtualenvs/bleeding/lib/python3.10/site-packages/matplotlib/cbook/__init__.py in CallbackRegistry.process(self, s, *args, **kwargs)
    228 except Exception as exc:
    229     if self.exception_handler is not None:
--> 230         self.exception_handler(exc)
    231     else:
    232         raise

~/.virtualenvs/bleeding/lib/python3.10/site-packages/matplotlib/cbook/__init__.py in _exception_printer(exc)
     80 def _exception_printer(exc):
     81     if _get_running_interactive_framework() in ["headless", None]:
---> 82         raise exc
     83     else:
     84         traceback.print_exc()

~/.virtualenvs/bleeding/lib/python3.10/site-packages/matplotlib/cbook/__init__.py in CallbackRegistry.process(self, s, *args, **kwargs)
    223 if func is not None:
    224     try:
--> 225         func(*args, **kwargs)
    226     # this does not capture KeyboardInterrupt, SystemExit,
    227     # and GeneratorExit
    228     except Exception as exc:

~/.virtualenvs/bleeding/lib/python3.10/site-packages/matplotlib/animation.py in Animation._start(self, *args)
    947 self._fig.canvas.mpl_disconnect(self._first_draw_id)
    949 # Now do any initial draw
--> 950 self._init_draw()
    952 # Add our callback for stepping the animation and
    953 # actually start the event_source.
    954 self.event_source.add_callback(self._step)

~/.virtualenvs/bleeding/lib/python3.10/site-packages/matplotlib/animation.py in FuncAnimation._init_draw(self)
   1688 def _init_draw(self):
   1689     # Initialize the drawing either using the given init_func or by
   1690     # calling the draw function with the first item of the frame sequence.
   1691     # For blitting, the init_func should return a sequence of modified
   1692     # artists.
   1693     if self._init_func is None:
-> 1694         self._draw_frame(next(self.new_frame_seq()))
   1696     else:
   1697         self._drawn_artists = self._init_func()

StopIteration: 
```

I am however at a loss for how @chisarie is triggering this issue and why saving a _different figure_ would trigger this.  If I run the code in the OP as a script (via `python test.py`) then I don't get a trace back so I suspect that does have something to do with coming back to the prompt (and something pulling up the GUI window).   I'll have a PR to fix this open later tonight (have a fix, just need to write the test).