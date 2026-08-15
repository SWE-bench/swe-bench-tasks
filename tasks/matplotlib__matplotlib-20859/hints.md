Yep that was just an oversight, not a design decision ;-)
I don't want to complicate this too much, but a further issue arrises even after changing the line I suggest above (let me know if this should be a separate issue)

```python
fig = plt.figure()
subfig = fig.subfigures()
ax = subfig.subplots()
ax.plot([0, 1, 2], [0, 1, 2], label="test")
subfig.legend()
print(fig.get_default_bbox_extra_artists())
```
doesn't include the legend and so the legend is cut off if saving the figure with `bbox_inches="tight"`:
```python
[<matplotlib.figure.SubFigure object at 0x7fb5cbbe8790>,
 <matplotlib.lines.Line2D object at 0x7fb5cbc0db50>,
 <matplotlib.spines.Spine object at 0x7fb5cadc73a0>,
 <matplotlib.spines.Spine object at 0x7fb5cb8ed820>,
 <matplotlib.spines.Spine object at 0x7fb5cb8ed6d0>,
 <matplotlib.spines.Spine object at 0x7fb5cad61f70>,
 <matplotlib.axis.XAxis object at 0x7fb5cadc7be0>,
 <matplotlib.axis.YAxis object at 0x7fb5cbbe8e50>,
 <matplotlib.patches.Rectangle object at 0x7fb5cbbfd760>]
```

Adding something like 
```python
if self.subfigs:
    return [artist for subfig in self.subfigs
            for artist in subfig.get_default_bbox_extra_artists()]
```
to the start of 
https://github.com/matplotlib/matplotlib/blob/62c1588f0fe245c79749d1e237f907af237de22b/lib/matplotlib/figure.py#L1578-L1584
seems to do the trick, but let me know if there are any better ideas.
OK, so all that logic seems wrong - `get_default_bbox_extra_artists` should probably _only_ return SubFigure, and its bbox should include the legend.  Can you indeed open a new issue for this? 
Can we add a legend like this way for the subplots?

![image](https://user-images.githubusercontent.com/78029145/127621783-1dbcbbc9-268b-4b19-ba03-352bac8a04f6.png)
