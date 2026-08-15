Sorry for the slow reply; if you can submit a PR that would be great!
This issue has been marked "inactive" because it has been 365 days since the last comment. If this issue is still present in recent Matplotlib releases, or the feature request is still wanted, please leave a comment and this label will be removed. If there are no updates in another 30 days, this issue will be automatically closed, but you are free to re-open or create a new issue if needed. We value issue reports, and this procedure is meant to help us resurface and prioritize issues that have not been addressed yet, not make them disappear.  Thanks for your help!
Perhaps #18875 would fix these issues?
I've ran into this issue a couple more times over the past years.
The inactivity notification was a good reminder to come back to this ...

The issue is still present.
With matplotlib 3.7.1 (and python 3.11.4 and numpy 1.24.3):
![image](https://github.com/matplotlib/matplotlib/assets/28384651/031747bd-b066-4b54-9604-f7af6f9d2b11)

<details>
<summary>
I've slightly condensed the figure from <a href="https://github.com/matplotlib/matplotlib/issues/12926#issue-386884240">my initial post</a>, the code to produce the figure above is here
</summary>

```python
from matplotlib import pyplot as plt
import numpy as np

plt.rcParams["font.size"] = 8
plt.rcParams["font.family"] = "Noto Sans"

np.random.seed(42)

X, Y = np.random.multivariate_normal([0.0, 0.0], [[1.0, 0.1], [0.1, 1.0]], size=250).T
Z = np.ones_like(X)

extent = [-3., 3., -3., 3.]  # doc: "Order of scalars is (left, right, bottom, top)"
gridsize = (7, 7)  # doc: "int or (int, int), optional, default is 100"
hexbin_kwargs = dict(
    extent=extent,
    gridsize=gridsize,
    linewidth=0.0,
    edgecolor='none',
    cmap='Blues',
)

N_AXS = 6
fig, axs = plt.subplots(int(np.ceil(N_AXS / 2)), 2, figsize=(8, 12))
axiter = iter(axs.ravel())

# call hexbin with varying parameters (C argument, mincnt, etc.):

ax = next(axiter)
ax.set_title("no mincnt specified, no C argument")
ax.hexbin(
    X, Y,
    **hexbin_kwargs,
)
ax.set_facecolor("green")  # for contrast
# shows a plot where all gridpoints are shown, even when the values are zero

ax = next(axiter)
ax.set_title("mincnt=1 specified, no C argument")
ax.hexbin(
    X, Y,
    mincnt=1,
    **hexbin_kwargs,
)
ax.set_facecolor("green")
# *all makes sense, so far*
# shows only a plot where gridpoints containing at least one datum are shown

ax = next(axiter)
ax.set_title("no mincnt specified, C argument specified")
ax.hexbin(
    X, Y,
    C=Z,
    reduce_C_function=np.sum,
    **hexbin_kwargs,
)
ax.set_facecolor("green")
# shows only a plot where gridpoints containing at least one datum are shown

ax = next(axiter)
ax.set_title("mincnt=1 specified, C argument specified")
ax.hexbin(
    X, Y,
    C=Z,
    reduce_C_function=np.sum,
    mincnt=1,
    **hexbin_kwargs,
)
ax.set_facecolor("green")
# hmm, unexpected...
# shows only a plot where gridpoints containing at least **two** data points are shown(!!!)

ax = next(axiter)
ax.set_title("mincnt=0 specified, C argument specified")
ax.hexbin(
    X, Y,
    C=Z,
    reduce_C_function=np.sum,
    mincnt=0,
    **hexbin_kwargs,
)
ax.set_facecolor("green")

# Highlight cells where sum == 0
ax = next(axiter)
ax.set_title("Cells where sum is zero (shaded black)")
ax.hexbin(
    X, Y,
    C=Z,
    reduce_C_function=lambda v: sum(v) == 0,
    mincnt=-np.inf,
    **(hexbin_kwargs | dict(cmap="binary")),
)
ax.set_facecolor("green")
```
</details>

@QuLogic #18875 does not improve things.. after installing https://github.com/MihaiBabiac/matplotlib/tree/bugfix/hexbin-marginals the figure renders the same. (and `plt.matplotlib.__version__ ==  '3.3.2+1554.g54bf12686'`, FWIW)

AFAICT the logic in [_axes.py](https://github.com/matplotlib/matplotlib/blob/5f297631c2f295b2f3b52cfddeb33f02567a07f5/lib/matplotlib/axes/_axes.py#LL4998) still needs to be revisited, although the code path is now slightly different compared to 2018.
Sorry for the slow reply; if you can submit a PR that would be great!
This issue has been marked "inactive" because it has been 365 days since the last comment. If this issue is still present in recent Matplotlib releases, or the feature request is still wanted, please leave a comment and this label will be removed. If there are no updates in another 30 days, this issue will be automatically closed, but you are free to re-open or create a new issue if needed. We value issue reports, and this procedure is meant to help us resurface and prioritize issues that have not been addressed yet, not make them disappear.  Thanks for your help!
Perhaps #18875 would fix these issues?
I've ran into this issue a couple more times over the past years.
The inactivity notification was a good reminder to come back to this ...

The issue is still present.
With matplotlib 3.7.1 (and python 3.11.4 and numpy 1.24.3):
![image](https://github.com/matplotlib/matplotlib/assets/28384651/031747bd-b066-4b54-9604-f7af6f9d2b11)

<details>
<summary>
I've slightly condensed the figure from <a href="https://github.com/matplotlib/matplotlib/issues/12926#issue-386884240">my initial post</a>, the code to produce the figure above is here
</summary>

```python
from matplotlib import pyplot as plt
import numpy as np

plt.rcParams["font.size"] = 8
plt.rcParams["font.family"] = "Noto Sans"

np.random.seed(42)

X, Y = np.random.multivariate_normal([0.0, 0.0], [[1.0, 0.1], [0.1, 1.0]], size=250).T
Z = np.ones_like(X)

extent = [-3., 3., -3., 3.]  # doc: "Order of scalars is (left, right, bottom, top)"
gridsize = (7, 7)  # doc: "int or (int, int), optional, default is 100"
hexbin_kwargs = dict(
    extent=extent,
    gridsize=gridsize,
    linewidth=0.0,
    edgecolor='none',
    cmap='Blues',
)

N_AXS = 6
fig, axs = plt.subplots(int(np.ceil(N_AXS / 2)), 2, figsize=(8, 12))
axiter = iter(axs.ravel())

# call hexbin with varying parameters (C argument, mincnt, etc.):

ax = next(axiter)
ax.set_title("no mincnt specified, no C argument")
ax.hexbin(
    X, Y,
    **hexbin_kwargs,
)
ax.set_facecolor("green")  # for contrast
# shows a plot where all gridpoints are shown, even when the values are zero

ax = next(axiter)
ax.set_title("mincnt=1 specified, no C argument")
ax.hexbin(
    X, Y,
    mincnt=1,
    **hexbin_kwargs,
)
ax.set_facecolor("green")
# *all makes sense, so far*
# shows only a plot where gridpoints containing at least one datum are shown

ax = next(axiter)
ax.set_title("no mincnt specified, C argument specified")
ax.hexbin(
    X, Y,
    C=Z,
    reduce_C_function=np.sum,
    **hexbin_kwargs,
)
ax.set_facecolor("green")
# shows only a plot where gridpoints containing at least one datum are shown

ax = next(axiter)
ax.set_title("mincnt=1 specified, C argument specified")
ax.hexbin(
    X, Y,
    C=Z,
    reduce_C_function=np.sum,
    mincnt=1,
    **hexbin_kwargs,
)
ax.set_facecolor("green")
# hmm, unexpected...
# shows only a plot where gridpoints containing at least **two** data points are shown(!!!)

ax = next(axiter)
ax.set_title("mincnt=0 specified, C argument specified")
ax.hexbin(
    X, Y,
    C=Z,
    reduce_C_function=np.sum,
    mincnt=0,
    **hexbin_kwargs,
)
ax.set_facecolor("green")

# Highlight cells where sum == 0
ax = next(axiter)
ax.set_title("Cells where sum is zero (shaded black)")
ax.hexbin(
    X, Y,
    C=Z,
    reduce_C_function=lambda v: sum(v) == 0,
    mincnt=-np.inf,
    **(hexbin_kwargs | dict(cmap="binary")),
)
ax.set_facecolor("green")
```
</details>

@QuLogic #18875 does not improve things.. after installing https://github.com/MihaiBabiac/matplotlib/tree/bugfix/hexbin-marginals the figure renders the same. (and `plt.matplotlib.__version__ ==  '3.3.2+1554.g54bf12686'`, FWIW)

AFAICT the logic in [_axes.py](https://github.com/matplotlib/matplotlib/blob/5f297631c2f295b2f3b52cfddeb33f02567a07f5/lib/matplotlib/axes/_axes.py#LL4998) still needs to be revisited, although the code path is now slightly different compared to 2018.