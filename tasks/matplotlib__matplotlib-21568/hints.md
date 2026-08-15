Can you reproduce this without Pandas?
Yes. Done with the following code:
``` python
from datetime import datetime, timedelta

import matplotlib
import matplotlib.pyplot as plt
import numpy as np

np.random.seed(1)
matplotlib.rcParams["text.usetex"] = True

dates = np.arange(datetime(2020, 1, 1), datetime(2020, 1, 1, 0, 10), timedelta(seconds=6))
data = np.random.rand(100)

fig, ax = plt.subplots(constrained_layout=True)
ax.plot(dates, data)
plt.savefig(matplotlib.__version__ + ".png")
```
From the image it looks like 3.3.4 did not render the dates using TeX. 3.4.3 does render with TeX but gets the spacing wrong.
Support for this came in #18558 but I guess protecting spaces didn't happen properly.  
I guess that's related to https://github.com/matplotlib/matplotlib/issues/18520#issuecomment-950178052.
Edit: I think I have a reasonable implementation of `\text` that can go on top of my current mathtext-related PRs, plus a couple of others...
I get the plot I want by monkey patching `_wrap_in_tex`:
``` python
def _wrap_in_tex(text):
    text = text.replace('-', '{-}').replace(":", r"{:}").replace(" ", r"\;")
    return '$\\mathdefault{' + text + '}$'

matplotlib.dates._wrap_in_tex = _wrap_in_tex
```
![3 4 3](https://user-images.githubusercontent.com/19758978/140027269-47341b72-64a2-4c80-a559-aa97c4ae29a3.png)


@anntzer @Hoxbro can either of you put in a PR for this?  
(I don't have a quick fix, it'd go on top of my mathtext prs plus some more...)
@anntzer Should I add a PR with my quick fix which you can then remove/update in a following PR?
Go for it.