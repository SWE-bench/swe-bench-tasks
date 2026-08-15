Please try to boil down the problem to a minimal example when reporting issues.

I've now done that for you:
```
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

fig, (ax1, ax2) = plt.subplots(1, 2, subplot_kw={'projection': '3d'})
ax1.scatter(1,1,1)
ax2.scatter(1,1,1, c='r')
ax1.set_visible(False)

plt.show()
```
**Output**
![grafik](https://user-images.githubusercontent.com/2836374/174673179-f5b14df5-7689-49eb-995a-4c97e31c3c43.png)

**Expected**
The left axes should be invisible.
