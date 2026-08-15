This has nothing to do with subfigures, right?  This happens if you specify x or y in supx/ylabel even on a normal figure, I think.  
Not sure.  I've only used suptitles to date.  Will do some more digging.  Cheers

```python
import matplotlib.pyplot as plt

fig, ax = plt.subplots(constrained_layout=True)
fig.supxlabel('Boo', x=0.54)
plt.show()
```
does the same thing.  I think this is an easy-ish fix, but you'll need a private workaround for now:

```python
lab = fig.supxlabel('Boo', x=0.7)
lab._autopos = True
```