Here's a full example and error trace:
```python
import matplotlib.pyplot as plt

fig = plt.figure()
plt.figtext(.5, .5, "foo", rotation=[90])
plt.show()
```

```python
Traceback (most recent call last):
  File "/Users/dstansby/github/matplotlib/lib/matplotlib/backends/backend_macosx.py", line 45, in _draw
    self.figure.draw(renderer)
  File "/Users/dstansby/github/matplotlib/lib/matplotlib/artist.py", line 74, in draw_wrapper
    result = draw(artist, renderer, *args, **kwargs)
  File "/Users/dstansby/github/matplotlib/lib/matplotlib/artist.py", line 51, in draw_wrapper
    return draw(artist, renderer, *args, **kwargs)
  File "/Users/dstansby/github/matplotlib/lib/matplotlib/figure.py", line 2879, in draw
    mimage._draw_list_compositing_images(
  File "/Users/dstansby/github/matplotlib/lib/matplotlib/image.py", line 132, in _draw_list_compositing_images
    a.draw(renderer)
  File "/Users/dstansby/github/matplotlib/lib/matplotlib/artist.py", line 51, in draw_wrapper
    return draw(artist, renderer, *args, **kwargs)
  File "/Users/dstansby/github/matplotlib/lib/matplotlib/text.py", line 671, in draw
    bbox, info, descent = textobj._get_layout(renderer)
  File "/Users/dstansby/github/matplotlib/lib/matplotlib/text.py", line 294, in _get_layout
    if key in self._cached:
TypeError: unhashable type: 'list'
```
I'm currently working on this (via. making a decorator to validate arg/kwarg types)
Note that `text.set_color` already has a hashable check for exactly the same reason.  