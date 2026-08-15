Yeah we do some dancing around when we save with bbox inches - so this seems to get caught in that. I tried to track it down, but the figure-saving stack is full of context managers, and I can't see where the layout manager gets reset.  Hopefully someone more cognizant of that part of the codebase can explain.  

Thanks for looking @jklymak 🙂
I think it is set (temporarily) here;
https://github.com/matplotlib/matplotlib/blob/018c5efbbec68f27cfea66ca2620702dd976d1b9/lib/matplotlib/backend_bases.py#L2356-L2357
It is, but I don't understand what `_cm_set` does to reset the layout engine after this.  Somehow it is dropping the old layout engine and making a new one, and the new one doesn't know that the old one was a 'compressed' engine.  
It calls `get_{kwarg}` and after running calls `set({kwarg}={old value})`. So here it calls `oldvalue = figure.get_layout_engine()` and `figure.set(layout_engine=oldvalue)`. Is `figure.set_layout_engine(figure.get_layout_engine())` working correctly?
I am way out of my depth here but

```python
import matplotlib.pyplot as plt

plt.rcParams['figure.constrained_layout.use'] = True
fig = plt.figure(layout="compressed")

print(fig.get_layout_engine()._compress)
fig.set_layout_engine(fig.get_layout_engine())
print(fig.get_layout_engine()._compress)

fig.savefig('foo.png', bbox_inches='tight')
print(fig.get_layout_engine()._compress)
```

```
True
True
False
```

Without the `rcParams` line, `fig.get_layout_engine()` returns `None` after the `savefig`.
I _think_ the problem is the call to `adjust_bbox`
https://github.com/matplotlib/matplotlib/blob/018c5efbbec68f27cfea66ca2620702dd976d1b9/lib/matplotlib/backend_bases.py#L2349-L2350

which explicity calls
https://github.com/matplotlib/matplotlib/blob/a3011dfd1aaa2487cce8aa7369475533133ef777/lib/matplotlib/_tight_bbox.py#L21

which will use the default constrained layout engine if the `rcParams` is set
https://github.com/matplotlib/matplotlib/blob/a3011dfd1aaa2487cce8aa7369475533133ef777/lib/matplotlib/figure.py#L2599-L2610