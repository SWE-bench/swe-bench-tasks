You can pass colors as rgba values, so like

```python
from matplotlib.colors import to_rgba
plt.eventplot([[0, 1, 2], [0.5, 2.3]], color=[to_rgba('r', .5), to_rgba('g', .2)])
```

should do it
But I don't want to specify the colors.
-_-
This is solved ?

Running:
```python
plt.eventplot([[0, 1, 2], [0.5, 2.3]], alpha=[0.5, 0.2])
```
produces the following plot:
![Figure_1](https://user-images.githubusercontent.com/92092328/199773535-f7a3aa06-74ed-4777-8d67-bd81a5c2660a.png)

Python: 3.8.10
matplotlib: 3.6.2
This got fixed as a side effect of #22451.
Is that example the expected behavior? I would expect the top row to both be 0.5 and the bottom row to all be 0.2.
You are right, the behavior was modified (likely unintendedly). While this was raising before, the alpha sequence is now cycling within each dataset / LineCollection. We instead want to sequentially take the alpha values one value per LineCollection.

This needs explicit handling at 

https://github.com/matplotlib/matplotlib/blob/cd185ab8622a22b752e951ac19f0e2308df55efb/lib/matplotlib/axes/_axes.py#L1377-L1386