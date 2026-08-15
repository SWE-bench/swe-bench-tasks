I can replicate but am a little confused about what's happening. Is there a reason you think that the line you called out is the culprit, or were you just poking around? If you move the suptitle text over to a coordinate like (.98, 1) you can see that it's actually still there is something being plotted over it. And yet, modifying the zorder property doesn't seem to help.

> Is there a specific reason to why it fetches the parent figure currently, since Subfigure is supposed to be a drop-in replacement for Figure ? 

Unfortunately this abstraction isn't perfect — the main methods that get called on the `Plotter._figure` object are `savefig` and `set_layout_engine`, which `SubFigure` doesn't have — I think there is a need to have a pointer to the parent figure, although maybe the behavior of `Plot.save` when it's being drawn on a subfigure is undefined. (Good point about the nested subplots edge case too).
Looks like this is replicable with pure matplotlib:

```python
f = plt.figure()
sfs = f.subfigures(1, 2)
sfs[0].subplots()
sfs[1].subplots()
f.suptitle("Test title")
```
![image](https://user-images.githubusercontent.com/315810/211165334-c97b95a9-aea6-40ab-9c03-4e75836ca0eb.png)

Reported upstream to matplotlib: https://github.com/matplotlib/matplotlib/issues/24910
However to OP was using constrained_layout and in pure matplotlib it does:

```python
f = plt.figure()
sfs = f.subfigures(1, 2, layout='constrained')
sfs[0].subplots()
sfs[1].subplots()
f.suptitle("Test title")
```

![Suptitle](https://user-images.githubusercontent.com/1562854/211210932-1113b4d0-0f66-47a8-89b4-4c04dd8d05b8.png)

Does the `Plot` object call `plt.tight_layout`?  That will override constrained_layout.  

